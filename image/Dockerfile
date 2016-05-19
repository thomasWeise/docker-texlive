#
# thomasweise/texlive
#
# This is an image with a basic TeX Live installation.
# 
# 
FROM debian:8.4
MAINTAINER Thomas Weise <tweise@ustc.edu.cn>

RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' >> /etc/apt/sources.list.d/jessie-backports.list &&\
    export LANG=C.UTF-8 &&\
    apt-get clean &&\
    apt-get update &&\
    apt-get autoclean -y &&\
    apt-get autoremove -y &&\
    apt-get update &&\
    apt-get install -f -y apt-utils &&\    
    apt-get install -f -y ghostscript=9.06* \
                          latex-cjk-common=4.8.3* \
                          latex-cjk-chinese=4.8.3* \ 
                          texlive-full=2014.* \
                          texlive-fonts-extra=2014.* \
                          texlive-fonts-recommended=2014.* \
                          texlive-lang-cjk=2014.* \
                          texlive-luatex=2014.* \
                          texlive-pstricks=2014.* \
                          texlive-xetex=2014.* &&\
    apt-get purge -f -y texlive-fonts-extra-doc \
                        texlive-fonts-recommended-doc \
                        texlive-humanities-doc \
                        texlive-latex-base-doc \
                        texlive-latex-extra-doc \
                        texlive-latex-recommended-doc \
                        texlive-metapost-doc \
                        texlive-pictures-doc \
                        texlive-pstricks-doc \
                        texlive-science-doc &&\
    apt-get clean &&\
    apt-get autoclean -y &&\
    apt-get autoremove -y &&\
    apt-get clean &&\
    rm -rf /tmp/* /var/tmp/* &&\
    rm -rf /var/lib/apt/lists/* &&\    
    rm -f /etc/ssh/ssh_host_*
    
ADD scripts /bin/