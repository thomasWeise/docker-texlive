#!/bin/bash -

# This script filters a PDF file and attempts to include
# as many fonts as possible. It works like filterPdf, but
# avoids image re-encoding.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$scriptDir/__filterPdf.sh" "$1" "-dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dColorConversionStrategy=/LeaveColorUnchanged"
