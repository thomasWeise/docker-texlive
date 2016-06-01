#!/bin/bash

document="$1"

echo "Beginning GhostScript runs in order to convert document '$document' file to pdf file."

gs -q -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true -dOptimize=true -dPreserveCopyPage=false -dPreserveEPSInfo=false -dPreserveHalftoneInfo=false -dPreserveOPIComments=false -dPreserveOverprintSettings=false -dPreserveSeparation=false -dPreserveDeviceN=false -dMaxBitmap=2147483647 -dDownsampleMonoImages=false -dDownsampleGrayImages=false -dDownsampleColorImages=false -dFastWebView=false -dNOPAUSE -dQUIET -dBATCH -dSAFER -sDEVICE=pdfwrite -r720x720 -dEPSCrop -dCompatibilityLevel=1.4 -sOutputFile="$document.pdf" -f "$document.eps" -c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" -c quit

gs -q -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true -dOptimize=true -dPreserveCopyPage=false -dPreserveEPSInfo=false -dPreserveHalftoneInfo=false -dPreserveOPIComments=false -dPreserveOverprintSettings=false -dPreserveSeparation=false -dPreserveDeviceN=false -dMaxBitmap=2147483647 -dDownsampleMonoImages=false -dDownsampleGrayImages=false -dDownsampleColorImages=false -dFastWebView=false -dNOPAUSE -dQUIET -dBATCH -dSAFER -sDEVICE=pdfwrite -r720x720 -dEPSCrop -dCompatibilityLevel=1.4 -sOutputFile="$document.pdf" -f "$document.eps" -c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" -c quit

echo "Done converting '$document' to pdf."