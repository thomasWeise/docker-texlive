#!/bin/bash -

## TeX Document Resolver Script
## $1 document

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialized variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

__tex__currentDir="${__tex__currentDir:-}"
if [[ -z "$__tex__currentDir" ]]; then
  export __tex__currentDir=$(pwd)
fi

__tex__fullDocument="${__tex__fullDocument:-}"
if [[ -z "$__tex__fullDocument" ]]; then
  export __tex__fullDocument=$(readlink -m "$1")
fi

__tex__relativeDocument="${__tex__relativeDocument:-}"
if [[ -z "$__tex__relativeDocument" ]]; then
  export __tex__relativeDocument=$(python -c "import os.path; print os.path.relpath('$__tex__fullDocument','${__tex__currentDir}')")
fi

__tex__document="${__tex__document:-}"
if [[ -z "$__tex__document" ]]; then
  export __tex__document="${__tex__relativeDocument%%.*}"
fi

echo "You want to compile document '$__tex__document', corresponding to full path '$__tex__fullDocument', which is '$__tex__relativeDocument' relative to current directory '$__tex__currentDir'."
cd "$__tex__currentDir"