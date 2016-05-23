# [thomasWeise/texlive](https://hub.docker.com/r/thomasweise/texlive/)

[![Image Layers and Size](https://imagelayers.io/badge/thomasweise/texlive:latest.svg)](https://imagelayers.io/?images=thomasweise%2Ftexlive:latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Stars](https://img.shields.io/docker/stars/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)

This is a Docker image containing a [TeX Live](https://en.wikipedia.org/wiki/TeX_Live) installation (version 2015.2016) with several support <a href="#user-content-3-scripts">scripts</a> for easing the compilation of [LaTeX](https://en.wikipedia.org/wiki/LaTeX) files to [PDF](https://en.wikipedia.org/wiki/Portable_Document_Format). The goal is to provide a unified environment for compiling LaTeX documents with predictable and reproducible behavior, while decreasing the effort needed to install and maintain the LaTeX installation. This image is designed to be especially suitable for a Chinese audience and comes with several pre-installed open Chinese fonts. 

## 0. Installing Docker

Docker can be understand following the guidelines below:

* for [Linux](https://docs.docker.com/linux/step_one/)
* for [Windows](https://docs.docker.com/windows/step_one/)
* for [MacOS](https://docs.docker.com/mac/step_one/)

## 1. Usage

Below, we discuss the various parameters that you can pass to this image when running it. If you have installed Docker, you do not need to make any additional provisions or take any actions: If you do `docker run -t -i thomasweise/texlive /bin/bash -l` or something like that (see below), the image will automatically be downloaded and installed from [docker hub](https://hub.docker.com/).

### 1.1. Base Usage

For compiling some document named `myDocument.tex` in folder `/my/path/to/document/` with `xelatex.sh` and use fonts in folder `/path/to/fonts/`, you would do something like:

    docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive /bin/bash -l
    cd '/doc/'
    xelatex.sh myDocument
    exit
    
This should leave the compiled PDF file in folder `/my/path/to/document/`.

The first line of the above example (`docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive /bin/bash -l`) will start the docker container and you will find yourself at the command line prompt of the (Bash) shell running inside the container. In the following lines, we execute commands inside this container and with `exit`, we close/shut down the container and return to the original terminal from which you started.

The `-v sourcepath:destpath` options are optional. They allow you to "mount" a folder (`sourcepath`) from your local system into the Docker container, where it becomes available as path `destpath`. We can use this method to allow the LaTeX compiler running inside the container to work on your LaTeX documents by mounting their folder into a folder named `/doc/`, for instance. But we can also mount an external folder with fonts into the Linux font directory structure. For this purpose, please always mount your local font directory into `/usr/share/fonts/external/`, as our helper script `fontcall.sh` (see points 1.2 and 3) expects additional fonts to appear there. 

If you just want to use (or snoop around in) the image without mounting external folders, you can run this image by using:

    docker run -t -i thomasweise/texlive:<VERSION> /bin/bash -l


### 1.2. Fonts

In some scenarios, you may need to use fonts that are not freely available under Linux and thus cannot be part of this image. In this case, you would have these fonts in a different folder (which could be your Windows Fonts folder). You can then use these fonts with XeLaTeX.

You can mount an external fonts folder via providing option `-v /path/to/fonts/:/usr/share/fonts/external/`, where `/path/to/fonts/` should be replaced with the path to your font folder. Then simply pre-pend `fontcall.sh` before any script or program invocation, e.g., do `fontcall.sh xelatex.sh myDocument`.

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
    
where `/path/to/fonts/` should be replaced with the path to your font folder. The script `fontcall.sh` will take care of setting up the external fonts for you. It will also relieve you from the need to do `chmod`. Just prepend `fontcall.sh` before calling any script.

## 2. Building and Components

The image has the following components:

- [`TeX Live`](http://www.tug.org/texlive/) version 2015.2016
- [`ghostscript`](http://ghostscript.com/) version 9.18

You can build it with

    docker build -t thomasweise/texlive .

## 3. Scripts

We provide a set of scripts (in `/bin/`) that can be used for compiling LaTeX documents:

### 3.1. Compiler Scripts

Usually, LaTeX compilation means to call the LaTeX compiler program, then BibTeX, then the compiler again, and then some conversion program from the respective compiler output format to PDF. With the compiler scripts, we try to condense these calls into a single program invocation.

- `latex.sh <document>` compile the LaTeX `<document>` with [LaTeX](https://en.wikipedia.org/wiki/LaTeX) (also do [BibTeX](https://en.wikipedia.org/wiki/BibTeX))
- `lualatex.sh <document>` compile the LaTeX `<document>` with [LuaLaTeX](https://en.wikipedia.org/wiki/LuaTeX) (also do [BibTeX](https://en.wikipedia.org/wiki/BibTeX))
- `pdflatex.sh <document>` compile the LaTeX `<document>` with [PdfLaTeX](https://en.wikipedia.org/wiki/pdfTeX) (also do [BibTeX](https://en.wikipedia.org/wiki/BibTeX))
- `xelatex.sh <document>` compile the LaTeX `<document>` with [XeLaTeX](https://en.wikipedia.org/wiki/XeLaTeX) (also do [BibTeX](https://en.wikipedia.org/wiki/BibTeX))
- `mintex.sh <document> <compiler1> <compiler2> ...` allows you to invoke an arbitrary selection of the above compiler scripts to produce the smallest `pdf`. Doing `mintex.sh mydoc latex lualatex xelatex`, for instance, will compile `mydoc.tex` with `latex.sh`, `lualatex.sh`, and `xelatex.sh` and keep the smallest resulting `pdf` file.

### 3.2. Utility Scripts

We also provide some utility scripts for working with `PDF`, `PS`, and `EPS` files.

- `eps2pdf.sh <document>` convert the `EPS` file `<document>` to `PDF`
- `filterPdf.sh <document>` transform a document (either in [PostScript](https://en.wikipedia.org/wiki/PostScript)/`PS`, `EPS`, or `PDF` format) to `PDF` and include as many of the fonts used inside the document into the final `PDF`. This allows to produce a `PDF` from a `.ps` file `<document>` which should display correctly on as many computers as possible. 
- `fontcall.sh <commad to call> <arg1> <arg2...>` prepend `fontcall.sh` to any normal command that you would like to invoke and its arguments to make sure that all fonts are properly set up.
- `sudo` is a pseudo-`sudo` command: Inside a Docker container, we don't need `sudo`. However, if you have a script or something that calls plain `sudo` (without additional arguments) just with a to-be-sudoed command, this script will emulate a `sudo`. By doing nothing.

## 4. License

This image is licensed under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007, which you can find in file [LICENSE.md](https://github.com/thomasWeise/docker-texlive/blob/master/LICENSE.md). The license applies to the way the image is built, while the software components inside the image are under the respective licenses chosen by their respective copyright holders.