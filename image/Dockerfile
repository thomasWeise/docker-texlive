#
# thomasweise/texlive
#
# This is an image with a basic TeX Live installation.
# Source: https://github.com/thomasWeise/docker-texlive/
# License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
# The license applies to the way the image is built, while the
# software components inside the image are under the respective
# licenses chosen by their respective copyright holders.
#
FROM thomasweise/docker-pandoc
MAINTAINER Thomas Weise <tweise@ustc.edu.cn>

RUN mkdir /usr/share/fonts/external/ &&\
    mkdir /doc/

VOLUME ["/doc/", "/usr/share/fonts/external/"]

ADD scripts /bin/

ENTRYPOINT ["/bin/__boot__.sh"]
