#!/bin/bash -

## (Pdf)LaTeX Compiler Script
## $1 executable
## $2 document to compile
## $3 post-processing command, if any, executed as $3 "x" where "x" is produced pdf

echo "Welcome to the LaTeX compiler script."

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

program="$1"
document="${2%%.*}"
post=${3:-}

currentDir=`pwd`
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$currentDir"
echo "Current dir: '$currentDir'. Script source dir: '$scriptDir'."

echo "Applying program '$program' to source file '$document'."

echo "First cleaning up temporary files from other LaTeX runs."
rm "${document}.aux" || true
rm "${document}.bbl" || true
rm "${document}.blg" || true
rm "${document}.dvi" || true
rm "${document}.ent" || true
rm "${document}.idx" || true
rm "${document}.log" || true
rm "${document}.nav" || true
rm "${document}.out" || true
rm "${document}.out.ps" || true
rm "${document}.pdf" || true
rm "${document}.ps" || true
rm "${document}.snm" || true
rm "${document}.synctex" || true
rm "${document}.synctex.gz" || true
rm "${document}.toc" || true
rm "${document}.vrb" || true

echo "We will perform runs of (Pdf)LaTeX/BibTeX until no internal files change anymore."

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
  ${program} "${document}"
  if (("$cycle" > 1)) ; then
    echo "This is cycle $cycle, so we need to run '$program' a second time."
    ${program} "${document}"
  fi
 
  for i in *.aux; do
    if [ "$i" != "$document"] && \
       [ "$i" != "$document.aux"] ; then
      echo "Applying 'bibtex' to '$i'."
      bibtex "$i"
    fi
  done
  echo "Applying 'bibtex' to '$document'."
  bibtex "${document}"
 
  auxHash=""
  for i in *.aux; do
    auxHashTemp=$(sha256sum "$i")
    auxHash="$auxHash$auxHashTemp"
  done
  
  bblHash=""
  for i in *.bbl; do
    bblHashTemp=$(sha256sum "$i")
    bblHash="$bblHash$bblHashTemp"
  done
  
  echo "Finished build cycle $cycle."
    
  if [ "$cycle" -ge 200 ]; then
    echo "Something odd is happening: We have performed $cycle cycles. That's too many. Let's quit."
    break
  fi
done

echo "The tool chain '$program', bibtex has been executed until nothing changed anymore."
echo "We now ensure that a proper pdf is built."

if [ -f "${document}.pdf" ]; then
  echo "Pdf file was produced: filter it in order to include all fonts."
  "$scriptDir/filterPdf.sh" "${document}.pdf"
  rm "${document}.original.pdf"
else
  echo "No pdf file was produced."
  if [ ! -f "${document}.ps" ]; then
    echo "No postscript (.ps) file was produced."
    if [ -f "${document}.dvi" ]; then
      echo "A dvi file was produced, converting it to postscript (.ps)."      
      dvips "${document}"
    fi
  fi
  if [ -f "${document}.ps" ]; then
    echo "A postscript (.ps) file was found, converting it to pdf."
    "$scriptDir/filterPdf.sh" "${document}.ps"
  fi
fi

echo "Now cleaning up temporary files."
rm "${document}.aux" || true
rm "${document}.bbl" || true
rm "${document}.blg" || true
rm "${document}.dvi" || true
rm "${document}.ent" || true
rm "${document}.idx" || true
rm "${document}.log" || true
rm "${document}.nav" || true
rm "${document}.out" || true
rm "${document}.out.ps" || true
rm "${document}.ps" || true
rm "${document}.snm" || true
rm "${document}.synctex" || true
rm "${document}.synctex.gz" || true
rm "${document}.toc" || true
rm "${document}.vrb" || true

if [ -f "${document}.pdf" ]; then 
  chmod 777 "${document}.pdf"
fi

if [[ -n "$post" ]]
then
  echo "The post-processing command '$post' was specified, executing '$post \"${document}.pdf\"'."
  $post "${document}.pdf"
fi

echo "LaTeX compilation finished."