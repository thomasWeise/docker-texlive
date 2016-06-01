#!/bin/bash -

## Invoke several compiler scripts to get the smallest possible PDF

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "Welcome MinLaTeX tool chain."
echo "We will invoke several pdf-LaTeX compilers in a row in the hope to obtain the smallest possible output."

document="${1%%.*}"
echo "You want to compile document '$document'."

currentDir=$(pwd)
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$currentDir"

echo "The current directory is '$currentDir' and the folder where we look for scripts is '$scriptDir'."

loopIndex=0
minSize=2147483647
bestCompiler="undefined"

for var in "$@"
do
    loopIndex=$((loopIndex+1))
    
    if (("$loopIndex" > 1)) ; then
      "$scriptDir/$var.sh" "$document"
      currentSize=$(stat -c%s "$document.pdf")
        
      if (("$loopIndex" > 2)) ; then
        if (("$loopIndex" < "$#")) ; then
          if (("$minSize" > "$currentSize")) ; then
            echo "The new document produced by $var has size $currentSize, which is smaller than the smallest one we have so far (size $minSize by $bestCompiler), so we will keep it."
            minSize="$currentSize"
            mv -f "$document.pdf" "$tempFile"
            bestCompiler="$var"
          else
            echo "The new document produced by $var has size $currentSize, which is not smaller than the smallest one we have so far (size $minSize by $bestCompiler), so we will delete it."
            rm -f "$document.pdf" || true
          fi
        else
          if (("$minSize" > "$currentSize")) ; then
            echo "The new document produced by $var has size $currentSize, which is smaller than the smallest one we have so far (size $minSize by $bestCompiler), so we will keep it."
            minSize="$currentSize"
            rm -f "$tempFile" || true
            bestCompiler="$var"
          else
            echo "The new document produced by $var has size $currentSize, which is not smaller than the smallest one we have so far (size $minSize by $bestCompiler), so we will delete it."
            mv -f "$tempFile" "$document.pdf"
          fi
        fi
      else
        minSize=$(stat -c%s "$document.pdf")
        if (("$loopIndex" < "$#")) ; then
          tempFile="$(tempfile -p=mintex -s=.pdf)"
          echo "We will use file '$tempFile' as temporary storage to hold the current-smallest pdf."
          mv -f "$document.pdf" "$tempFile"
        fi
        bestCompiler="$var"
        echo "Compiler $var has produced the first pdf document in this MinLaTeX run. It has size $minSize."
      fi
    fi
done

echo "Finished MinLaTeX tool chain: produced document of size $minSize (with compiler '$bestCompiler')."