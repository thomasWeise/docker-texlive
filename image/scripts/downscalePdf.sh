#!/bin/bash


# Make a pdf File Smaller by downscaling all included images

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


echo "Make a pdf File Smaller by downscaling all included images."

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

resolution=${2:-}

if [[ -n "$resolution" ]]
then
  echo "The resolution '$resolution' was specified."
else
resolution=192
  echo "No resolution was specified, using '$resolution'."
fi

echo "Downscaling '$useSource' to '$dest'."

gs -q -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true \
  -dOptimize=true \
  -dPreserveCopyPage=false -dPreserveEPSInfo=false -dPreserveHalftoneInfo=false \
  -dPreserveOPIComments=false -dPreserveOverprintSettings=false \
  -dPreserveSeparation=false -dPreserveDeviceN=false \
  -dMaxBitmap=2147483647 \
  -dDownsampleMonoImages=true -dDownsampleGrayImages=true -dDownsampleColorImages=true \
  -dColorImageDownsampleType=/Bicubic -dGrayImageDownsampleType=/Bicubic \
  -dMonoImageDownsampleType=/Bicubic \
  -dColorImageResolution=$resolution -dGrayImageResolution=$resolution -dMonoImageResolution=$resolution \
  -dFastWebView=false \
  -dNOPAUSE -dQUIET -dBATCH -dSAFER -sDEVICE=pdfwrite -dAutoRotatePages=/PageByPage \
  -sOutputFile="$dest" "$useSource" \
  -c .setpdfwrite "<</NeverEmbed [ ]>> setdistillerparams"


chmod 777 "$dest" || true

echo "Finished creating downsampled, smaller version."

