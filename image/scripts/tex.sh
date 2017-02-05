#!/bin/bash -

## [La|LuaLa|Pdf|XeLa]TeX Compiler Script
## $2 executable
## $1 __tex__document to compile

echo "Welcome to the [La|LuaLa|PdfLa|XeLa]TeX compiler script."

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

program="$2"
echo "You have chosen the '$program' compiler with options '${@:3}'."

# setup the (relative) paths
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$scriptDir/__texSetup__.sh"

cd "$__tex__currentDir"
echo "First we will do some cleaning up temporary files from other LaTeX runs and also delete any pre-existing version of '$__tex__document.pdf'."
rm "$__tex__document.aux" || true
rm "$__tex__document.bbl" || true
rm "$__tex__document.blg" || true
rm "$__tex__document.dvi" || true
rm "$__tex__document.ent" || true
rm "$__tex__document.idx" || true
rm "$__tex__document.log" || true
rm "$__tex__document.nav" || true
rm "$__tex__document.out" || true
rm "$__tex__document.out.ps" || true
rm "$__tex__document.pdf" || true
rm "$__tex__document.ps" || true
rm "$__tex__document.snm" || true
rm "$__tex__document.spl" || true
rm "$__tex__document.synctex" || true
rm "$__tex__document.synctex.gz" || true
rm "$__tex__document.toc" || true
rm "$__tex__document.vrb" || true
rm "texput.log" || true

echo "Now removing Unicode BOMs of .tex and .sty files, if any, as they will confuse LaTeX compilers"
find "$__tex__currentDir" -name '*.sty' -exec "$scriptDir/removeBOM.sh" "{}" \;
find "$__tex__currentDir" -name '*.bib' -exec "$scriptDir/removeBOM.sh" "{}" \;
find "$__tex__currentDir" -name '*.tex' -exec "$scriptDir/removeBOM.sh" "{}" \;

echo "We will perform runs of $program/BibTeX until no internal files change anymore."

auxHash=""
oldAuxHash="old"
bblHash=""
oldBblHash="old"
cycle=0

while [ "$oldAuxHash" != "$auxHash" ] || \
      [ "$oldBblHash" != "$bblHash" ]; do
  cycle=$((cycle+1))
  echo "Now beginning build cycle $cycle."

  oldAuxHash=$auxHash
  oldBblHash=$bblHash

  echo "Running '$program'."
  set +o errexit
  "$program" "${@:3}" "$__tex__document"
  retVal=$?
  set -o errexit
  if(("$retVal" != 0)) ; then
    echo "Error: Program '$program' returned '$retVal' when compiling '$__tex__document'. Now exiting."
    exit "$retVal"
  fi

  for i in *.aux; do
    if [ "$i" != "$__tex__document" ] && \
       [ "$i" != "$__tex__document.aux" ] ; then
      if [ -f "$i" ]; then
        if grep -q "\\citation{" "$i.aux"; then
          echo "File '$i' contains citations, so we applying 'bibtex' to it."
          bibtex "$i"
          echo "Finished applying 'bibtex' to '$i.aux'."
        else
          echo "File '$i' does not contain any citation, so we do not apply 'bibtex'."
        fi
      fi
    fi
  done


  if grep -q "\\citation{" "$__tex__document.aux"; then
    echo "File '$__tex__document.aux' contains citations, so we applying 'bibtex' to it."
    bibtex "$__tex__document"
    echo "Finished applying 'bibtex' to '$__tex__document.aux'."
  else
    echo "File '$__tex__document.aux' does not contain any citation, so we do not apply 'bibtex'."
  fi

  auxHash=""
  for i in *.aux; do
    if [ -f "$i" ]; then
      auxHashTemp=$(sha256sum "$i")
      auxHash="$auxHash$auxHashTemp"
    fi
  done

  bblHash=""
  for i in *.bbl; do
    if [ -f "$i" ]; then
      bblHashTemp=$(sha256sum "$i")
      bblHash="$bblHash$bblHashTemp"
    fi
  done

  echo "Finished build cycle $cycle."

  if (("$cycle" > 200)) ; then
    echo "Something odd is happening: We have performed $cycle cycles. That's too many. Let's quit."
    break
  fi
done

echo "The tool chain '$program'+BibTeX has been executed until nothing changed anymore."

laTeXWarnings=0
laTeXWarning=""
if [ -f "$__tex__document.log" ]; then
  echo "We now check that the compilation was successful by 'grep'ing the log file $__tex__document.log for common errors/warnings."

  if grep -q "LaTeX Warning: There were undefined references." "$__tex__document.log"; then
    laTeXWarnings=$((laTeXWarnings+1))
    laTeXWarning="${laTeXWarning}"$'\n'"${laTeXWarnings}. The __tex__document contains undefined references. Please fix them (search file $__tex__document.log for patterns 'undefined reference' and 'LaTeX Warning: Reference')."
  fi
  if grep -q "LaTeX Warning: There were multiply-defined labels." "$__tex__document.log"; then
    laTeXWarnings=$((laTeXWarnings+1))
    laTeXWarning="${laTeXWarning}"$'\n'"${laTeXWarnings}. The __tex__document contains multiply defined labels, i.e., labels defined more than once. Please fix them (search file $__tex__document.log for pattern 'multiply-defined')."
  fi
  if grep -q "Missing character: There is no" "$__tex__document.log"; then
    laTeXWarnings=$((laTeXWarnings+1))
    laTeXWarning="${laTeXWarning}"$'\n'"${laTeXWarnings}. The __tex__document contains some characters which cannot be printed. Please fix them (check file $__tex__document.log for pattern 'Missing character: There is no')."
  fi
  if grep -q "Empty ‘thebibliography’ environment" "$__tex__document.log"; then
    laTeXWarnings=$((laTeXWarnings+1))
    laTeXWarning="${laTeXWarning}"$'\n'"${laTeXWarnings}. The __tex__document contains an empty bibliography environment. Maybe you should not use a bibliography if there are no citations? Please fix them (check file $__tex__document.log for pattern 'Empty ‘thebibliography’ environment')."
  fi
  if grep -q "Float too large for page by" "$__tex__document.log"; then
    laTeXWarnings=$((laTeXWarnings+1))
    laTeXWarning="${laTeXWarning}"$'\n'"${laTeXWarnings}. At least one floating object such as a table or figure is too large. Please fix them (check file $__tex__document.log for pattern 'Float too large for page by')."
  fi
fi


echo "We now ensure that a proper pdf is built."

if [ -f "$__tex__document.pdf" ]; then
  echo "Pdf file '$__tex__document.pdf' was produced: we will filter it in order to include all fonts."
  "$scriptDir/filterPdf.sh" "$__tex__document.pdf"
  rm "$__tex__document.original.pdf"
else
  echo "No pdf file '$__tex__document.pdf' was produced."
  if [ ! -f "$__tex__document.ps" ]; then
    echo "No postscript (.ps) file '$__tex__document.ps' was produced."
    if [ -f "$__tex__document.dvi" ]; then
      echo "The dvi file '$__tex__document.dvi' was produced, converting it to postscript (.ps)."
      dvips "$__tex__document"
    fi
  fi
  if [ -f "$__tex__document.ps" ]; then
    echo "A postscript (.ps) file '$__tex__document.ps' was found, converting it to pdf."
    "$scriptDir/filterPdf.sh" "$__tex__document.ps"
  fi
fi

echo "Now cleaning up temporary files."
rm "$__tex__document.aux" || true
rm "$__tex__document.bbl" || true
rm "$__tex__document.blg" || true
rm "$__tex__document.dvi" || true
rm "$__tex__document.ent" || true
rm "$__tex__document.idx" || true
if (("$laTeXWarnings" < 1)) ; then
  rm "$__tex__document.log" || true
fi
rm "$__tex__document.nav" || true
rm "$__tex__document.out" || true
rm "$__tex__document.out.ps" || true
rm "$__tex__document.ps" || true
rm "$__tex__document.snm" || true
rm "$__tex__document.spl" || true
rm "$__tex__document.synctex" || true
rm "$__tex__document.synctex.gz" || true
rm "$__tex__document.toc" || true
rm "$__tex__document.vrb" || true
rm "texput.log" || true

if [ -f "$__tex__document.pdf" ]; then
  echo "We change the access permissions of the produced document '$__tex__document.pdf' to 777."
  chmod 777 "$__tex__document.pdf"
fi

if (("$laTeXWarnings" < 1)) ; then
  echo "[La|LuaLa|Pdf|XeLa]TeX compilation finished successfully."
  exit 0
else
  echo "[La|LuaLa|Pdf|XeLa]TeX compilation has not finished successfully, there were some fishy LaTeX warnings. We tried to build a PDF anyway, though:$laTeXWarning"
  exit 1
fi