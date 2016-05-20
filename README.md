# [thomasWeise/texlive](https://hub.docker.com/r/thomasweise/texlive/)

[![Image Size](https://img.shields.io/imagelayers/image-size/thomasweise/texlive/latest.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Image Layers](https://img.shields.io/imagelayers/layers/thomasweise/texlive/latest.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Stars](https://img.shields.io/docker/stars/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)

This is a docker container containing an up-to-date TeXLive installation with some support scripts.

## Usage

For compiling some document named `myDocument.tex` in folder `/my/path/to/document/` with `xelatex.sh`, you would do something like:

    docker run -v /my/path/to/document/:/doc/ -t -i thomasweise/texlive /bin/bash -l
    cd `/doc/`
    pdflatex.sh myDocument
    exit

You can run this image by using:

    docker run -t -i thomasweise/texlive:<VERSION> /bin/bash -l
	
to look around in the image.

## Building and Components

The image has the following components:

- [`TeX Live`](http://www.tug.org/texlive/) version 2014
- [`ghostscript`](http://ghostscript.com/) version 9.06

You can build it with

    docker build -t thomasweise/texlive .

## Scripts

We provide a set of scripts (in `/bin/`) that can be used for compiling LaTeX documents:

- `latex.sh <document>` compile the LaTeX `<document>` with LaTeX (also do BibTeX)
- `pdflatex.sh <document>` compile the LaTeX `<document>` with PdfLaTeX (also do BibTeX)
- `xelatex.sh <document>` compile the LaTeX `<document>` with XeLaTeX (also do BibTeX)
- `eps2pdf.sh <document>` convert the EPS file `<document>` to PDF
- `filterPdf.sh <document>` include as many of the used fonts into a PDF produced from a PS or PDF document `<document>` 