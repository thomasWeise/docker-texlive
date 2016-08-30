#!/bin/bash -

## [La|LuaLa|Pdf|XeLa]TeX Compiler Script
## $1 executable
## $2 document to compile

echo "Welcome to the [La|LuaLa|PdfLa|XeLa]TeX compiler script."

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

program="$1"
echo "You have chosen the '$program' compiler with options '${@:3}'."

document="${2%%.*}"
echo "You want to compile document '$document'."

currentDir=$(pwd)
echo "Your current working directory is '$currentDir'."

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "This script is in directory '$scriptDir', where we also will look for other scripts."

cd "$currentDir"
echo "First we will do some cleaning up temporary files from other LaTeX runs and also delete any pre-existing version of '$document.pdf'."
rm "$document.aux" || true
rm "$document.bbl" || true
rm "$document.blg" || true
rm "$document.dvi" || true
rm "$document.ent" || true
rm "$document.idx" || true
rm "$document.log" || true
rm "$document.nav" || true
rm "$document.out" || true
rm "$document.out.ps" || true
rm "$document.pdf" || true
rm "$document.ps" || true
rm "$document.snm" || true
rm "$document.synctex" || true
rm "$document.synctex.gz" || true
rm "$document.toc" || true
rm "$document.vrb" || true

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
  "$program" "${@:3}" "$document"
  retVal=$?
  set -o errexit
  if(("$retVal" != 0)) ; then
    echo "Error: Program '$program' returned '$retVal' when compiling '$document'. Now exiting."
    exit "$retVal"
  fi
  
  for i in *.aux; do
    if [ "$i" != "$document" ] && \
       [ "$i" != "$document.aux" ] ; then
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
  
  
  if grep -q "\\citation{" "$document.aux"; then
    echo "File '$document.aux' contains citations, so we applying 'bibtex' to it."
    bibtex "$document"
    echo "Finished applying 'bibtex' to '$document.aux'."
  else
    echo "File '$document.aux' does not contain any citation, so we do not apply 'bibtex'."
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
echo "We now ensure that a proper pdf is built."

if [ -f "$document.pdf" ]; then
  echo "Pdf file '$document.pdf' was produced: we will filter it in order to include all fonts."
  "$scriptDir/filterPdf.sh" "$document.pdf"
  rm "$document.original.pdf"
else
  echo "No pdf file '$document.pdf' was produced."
  if [ ! -f "$document.ps" ]; then
    echo "No postscript (.ps) file '$document.ps' was produced."
    if [ -f "$document.dvi" ]; then
      echo "The dvi file '$document.dvi' was produced, converting it to postscript (.ps)."      
      dvips "$document"
    fi
  fi
  if [ -f "$document.ps" ]; then
    echo "A postscript (.ps) file '$document.ps' was found, converting it to pdf."
    "$scriptDir/filterPdf.sh" "$document.ps"
  fi
fi

echo "Now cleaning up temporary files."
rm "$document.aux" || true
rm "$document.bbl" || true
rm "$document.blg" || true
rm "$document.dvi" || true
rm "$document.ent" || true
rm "$document.idx" || true
rm "$document.log" || true
rm "$document.nav" || true
rm "$document.out" || true
rm "$document.out.ps" || true
rm "$document.ps" || true
rm "$document.snm" || true
rm "$document.synctex" || true
rm "$document.synctex.gz" || true
rm "$document.toc" || true
rm "$document.vrb" || true

if [ -f "$document.pdf" ]; then
  echo "We change the access permissions of the produced document '$document.pdf' to 777." 
  chmod 777 "$document.pdf"
fi

echo "[La|LuaLa|Pdf|XeLa]TeX compilation finished."