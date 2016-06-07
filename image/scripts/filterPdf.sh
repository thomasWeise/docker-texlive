#!/bin/bash -

# This script filters a PDF file and attempts to include
# as many fonts as possible.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

echo "Filtering document '$1' in order to include as many fonts as possible."

source="$1"
name="${source%%.*}"
dest="$name.pdf"

if [ -f "$dest" ]; then
  useSource="$name.original.pdf"
  echo "Creating backup '$useSource' of '$dest'."
  cp "$dest" "$useSource"
else
  useSource="$source"
fi

echo "Filtering '$useSource' to '$dest'."

gs -q -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true \
   -dOptimize=true -dPreserveCopyPage=false -dPreserveEPSInfo=false \
   -dPreserveHalftoneInfo=false -dPreserveOPIComments=false \
   -dPreserveOverprintSettings=false -dPreserveSeparation=false \
   -dPreserveDeviceN=false -dMaxBitmap=2147483647 \
   -dDownsampleMonoImages=false -dDownsampleGrayImages=false \
   -dDownsampleColorImages=false -dDetectDuplicateImages=true \
   -dHaveTransparency=true -dFastWebView=false \
   -dNOPAUSE -dQUIET -dBATCH -dSAFER -sDEVICE=pdfwrite \
   -dAutoRotatePages=/PageByPage -sOutputFile="$dest" "$useSource" \
   -c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams"

chmod 777 "$dest" || true

echo "Done filtering document '$source' to '$dest'."