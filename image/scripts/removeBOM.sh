#!/bin/bash -

# This script removes a Byte Order Mark from a text file.

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

source="$1"

echo "Trying to detect and, if present, remove Byte Order Mark (BOM) from document '$source'."

if ($( head -c3 "$source" | grep -q $'\xef\xbb\xbf' )); then
  echo "3-byte BOM detected in '$source', now removing it."
  tempFileName=$(tempfile)
  tail --bytes=+4 "$source" >"$tempFileName"
  mv -f "$tempFileName" "$source"
  echo "Done removing 3-byte Byte Order Mark (BOM) from document '$source'."
else
  echo "No BOM detected in '$source', doing nothing."
fi