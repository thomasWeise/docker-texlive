# [thomasWeise/texlive](https://hub.docker.com/r/thomasweise/texlive/)

[![Image Size](https://img.shields.io/imagelayers/image-size/thomasweise/texlive/latest.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Image Layers](https://img.shields.io/imagelayers/layers/thomasweise/texlive/latest.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Stars](https://img.shields.io/docker/stars/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)

This is a docker container containing an up-to-date TeXLive installation with some support scripts.

## 1. Usage

### 1.1. Base Usage

For compiling some document named `myDocument.tex` in folder `/my/path/to/document/` with `xelatex.sh`, you would do something like:

    docker run -v /my/path/to/document/:/doc/ -t -i thomasweise/texlive /bin/bash -l
    cd '/doc/'
    xelatex.sh myDocument
    exit

You can run this image by using:

    docker run -t -i thomasweise/texlive:<VERSION> /bin/bash -l
	
to look around in the image.

### 1.2. Fonts

In some scenarios, you may need to use fonts that are not freely available under Linux and thus cannot be part of this image. In this case, you would have these fonts in a different folder (which could be your Windows Fonts folder).

You can mount an external fonts folder via providing option `-v /path/to/fonts/:/usr/share/fonts/external/`. Then simply pre-pend `fontcall.sh` before any script or program invocation, e.g., do `fontcall.sh xelatex.sh myDocument`.

A typical example would be the [USTC thesis template](https://github.com/ustctug/ustcthesis) for which a build script called `make.sh` is provided. If you have mounted your thesis draft into folder `/doc`, you would do:

    cd /doc/
    chmod +X ./make.sh
    ./make.sh
    
and obtain the error message

    ...
    ...
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    !
    ! fontspec error: "font-not-found"
    ! 
    ! The font "SimSun" cannot be found.
    ! 
    ! See the fontspec documentation for further information.
    ! 
    ! For immediate help type H <return>.
    !...............................................  
                                                      
    l.5   {SimSun}
                                          
The solution for this problem would be to mount a folder with missing fonts (which will normally be located in `C:\Windows\Fonts`) into the container and try:

    docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive /bin/bash -l
    cd /doc/
    fontcall.sh make.sh
    
The script `fontcall.sh` will take care of setting up the external fonts for you. It will also relieve you from the need to do `chmod`. Just prepend `fontcall.sh` before calling any script.

## 2. Building and Components

The image has the following components:

- [`TeX Live`](http://www.tug.org/texlive/) version 2014
- [`ghostscript`](http://ghostscript.com/) version 9.06

You can build it with

    docker build -t thomasweise/texlive .

## 3. Scripts

We provide a set of scripts (in `/bin/`) that can be used for compiling LaTeX documents:

- `latex.sh <document>` compile the LaTeX `<document>` with LaTeX (also do BibTeX)
- `pdflatex.sh <document>` compile the LaTeX `<document>` with PdfLaTeX (also do BibTeX)
- `xelatex.sh <document>` compile the LaTeX `<document>` with XeLaTeX (also do BibTeX)
- `eps2pdf.sh <document>` convert the EPS file `<document>` to PDF
- `filterPdf.sh <document>` include as many of the used fonts into a PDF produced from a PS or PDF document `<document>` 