#!/bin/bash -

# strict error handling
set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

script="$1"
currentDir=$(pwd)

echo "This is the fontcall.sh utility, which allows you to provide external fonts to your [Xe|La|Pdf]TeX program."
echo "You invoke '$script' in folder '$currentDir'."
echo "Many fonts are copyrighted and cannot be included in a Docker image."
echo "You may mount an external directory with fonts into the container by providing the following option to 'docker run':"
echo "    -v /path/to/fonts/:/usr/share/fonts/external/"
echo "Then, you can use these fonts by pre-pending 'fontcall.sh' to any other script invocation, i.e., do something like:"
echo "    fontcall.sh xelatex.sh myDocument"

if [ -d "/usr/share/fonts/external" ]; then
  if [ -d "/usr/share/fonts/external2" ]; then
    echo "External fonts have already been initialized."
  else
    echo "External fonts will now be initialized (by dealing with case-sensitive file names)."
    mkdir "/usr/share/fonts/external2"
    cd "/usr/share/fonts/external2"
    find -L ../external/ -type f -name "*.*" -exec cp "{}" . \; 
    rename 's/^([^.]*)\.(.*)$/\U$1\E.\U$2/' *
  fi
else
  echo "No external founts have been mounted."
fi

cd "$currentDir"
if [ -f "$currentDir/$script" ]; then
  echo "Script exists in current folder."
  chmod +x "$currentDir/$script"
  "$currentDir/$script" "${@:2}"
else
  echo "Script is assumed to be in /bin."
  "$script" "${@:2}"
fi