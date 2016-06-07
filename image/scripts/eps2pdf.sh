#!/bin/bash

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

document="${1%%.*}"

echo "Using GhostScript to convert document '$document.eps' file to '$document.pdf'."

gs -q -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true -dOptimize=true \
      -dPreserveCopyPage=false -dPreserveEPSInfo=false -dPreserveHalftoneInfo=false \
      -dPreserveOPIComments=false -dPreserveOverprintSettings=false -dPreserveSeparation=false \
      -dPreserveDeviceN=false -dMaxBitmap=2147483647 -dDownsampleMonoImages=false \
      -dDownsampleGrayImages=false -dDownsampleColorImages=false -dFastWebView=false \
      -dNOPAUSE -dQUIET -dBATCH -dSAFER -sDEVICE=pdfwrite -r720x720 -dEPSCrop \
      -dCompatibilityLevel=1.4 -sOutputFile="$document.pdf" -f "$document.eps" \
      -c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" -c quit

chmod 777 "$document.pdf" || true

echo "Done converting '$document.eps' to '$document.pdf'."