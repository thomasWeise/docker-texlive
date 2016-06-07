#!/bin/bash -

## Invoke XeLaTeX

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "Welcome to the XeLaTeX compiler script."

document="${1%%.*}"
echo "You want to compile document '$document'."
post=${2:-}

currentDir=$(pwd)
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$currentDir"

echo "The current directory is '$currentDir' and the folder where we look for scripts is '$scriptDir'."
echo "We will now invoke the 'tex.sh' tool chain."

"$scriptDir/tex.sh" xelatex "${document}" -halt-on-error

if [[ -n "$post" ]]
then
  echo "The post-processing command '$post' was specified, now executing '$post \"${document}.pdf\"'."
  $post "${document}.pdf"
fi

echo "Finished executing the XeLaTeX compiler script."