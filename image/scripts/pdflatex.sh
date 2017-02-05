#!/bin/bash -

## Invoke PdfLaTeX

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "Welcome to the PdfLaTeX compiler script."
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$scriptDir/__texSetup__.sh"

post=${2:-}
echo "The current directory is '$__tex__currentDir' and the folder where we look for scripts is '$scriptDir'."
echo "We will now invoke the 'tex.sh' tool chain."

"$scriptDir/tex.sh" "${__tex__document}" pdflatex -halt-on-error -interaction=nonstopmode

if [[ -n "$post" ]]
then
  echo "The post-processing command '$post' was specified, now executing '$post \"${__tex__document}.pdf\"'."
  $post "${__tex__document}.pdf"
fi

echo "Finished executing the PdfLaTeX compiler script."