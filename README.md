# [thomasWeise/texlive](https://hub.docker.com/r/thomasweise/texlive/)

[![Image Layers and Size](https://imagelayers.io/badge/thomasweise/texlive:latest.svg)](https://imagelayers.io/?images=thomasweise%2Ftexlive:latest)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)
[![Docker Stars](https://img.shields.io/docker/stars/thomasweise/texlive.svg)](https://hub.docker.com/r/thomasweise/texlive/)

This is a Docker image containing a [TeX Live](https://en.wikipedia.org/wiki/TeX_Live) installation (version 2015.2016) with several support <a href="#user-content-3-scripts">scripts</a> for easing the compilation of [LaTeX](https://en.wikipedia.org/wiki/LaTeX) files to [PDF](https://en.wikipedia.org/wiki/Portable_Document_Format). The goal is to provide a unified environment for compiling LaTeX documents with predictable and reproducible behavior, while decreasing the effort needed to install and maintain the LaTeX installation. This image is designed to be especially suitable for a Chinese audience and comes with several pre-installed open Chinese fonts.

## 0. Installing Docker

Docker can be installed following the guidelines below:

* for [Linux](https://docs.docker.com/linux/step_one/), you can run  `curl -fsSL https://get.docker.com/ | sh` on your command line and everything is done automatically (if you have `curl` installed, which is normally the case),
* for [Windows](https://docs.docker.com/windows/step_one/)
* for [Mac OS](https://docs.docker.com/mac/step_one/)

## 1. Usage

Below, we discuss the various parameters that you can pass to this image when running it. If you have installed Docker, you do not need to perform any additional installations: The first time you do `docker run -t -i thomasweise/texlive` or something like that (see below), the image will automatically be downloaded and installed from [docker hub](https://hub.docker.com/).

There are two basic use cases of this image:

1. Execution of a single command or script
2. Providing a shell where you can use all the standard LaTeX commands and our helper scripts 

Additionally, there are two ways to provide data to the container:

1. Mounting the folder where the LaTeX document you want to compile is located: This step is necessary..
2. Mounting a folder with additional fonts needed for compiling your document: This is optional.

The common form of the command is as follows:

    docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive COMMAND ARG1 ARG2...
    
Where

* `/my/path/to/document/` must be replaced with the path to the folder containing the LaTeX document that you want to compile. This folder will be made available as folder `/doc/` inside the container. If you use the image without command parameters (see below), you will get a bash command prompt inside this `/doc/` folder.
* Sometimes you may need additional fonts to compile your LaTeX document. An example for this situation is if you use something like the [USTC thesis template](https://github.com/ustctug/ustcthesis), which needs fonts such as SimHei from Windows, which are not available under Linux. In this case, you can use the *optional* `-v /path/to/fonts/:/usr/share/fonts/external/` parameter. Here, `/path/to/fonts/` must be replaced with a path to a folder containing these fonts. If you do not need additional fonts, you can leave the whole `-v /path/to/fonts/:/usr/share/fonts/external/` away.
* *Optinally* you can also provide a single command that should be executed when the container starts (along with its arguments). This is what the `COMMAND ARG1 ARG2...` in the above command line stand for. If you specify such a command, the container will start up, execute the command, and then shut down. If you do not provide such a command, the container will start up and provide you a bash prompt in folder `/doc/`.

For compiling some document named `myDocument.tex` in folder `/my/path/to/document/` with `xelatex.sh` and using additional fonts in folder `/path/to/fonts/`, you would type something like the command below into a normal terminal (Linux), the *Docker Quickstart Terminal* (Mac OS), or the *Docker Toolbox Terminal* (Windows):

    docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive
    xelatex.sh myDocument
    exit
    
Alternatively, you could also do

    docker run -v /my/path/to/document/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive xelatex.sh myDocument
    
The first version starts the container and leaves you at the command prompt. You can now compile your document using our `xelatex.sh` helper script, then you `exit` the container. In the second version, you directly provide the command to the container. The container executes it and then directly exits.
  
Both should leave the compiled PDF file in folder `/my/path/to/document/`. If you are not using my pre-defined scripts for building (see below under point 3.1), I recommend doing `chmod 777 myDocument.pdf` after the compilation, to ensure that the produced document can be accessed inside your real (host) system's user, and not just from the Docker container. If you directly provide a single command for execution, the container attempts to heuristically find your produced `pdf` and to set its permissions correctly. 

The `-v sourcepath:destpath` options are optional. They allow you to "mount" a folder (`sourcepath`) from your local system into the Docker container, where it becomes available as path `destpath`. We can use this method to allow the LaTeX compiler running inside the container to work on your LaTeX documents by mounting their folder into a folder named `/doc/`, for instance. But we can also mount an external folder with fonts into the Linux font directory structure. For this purpose, please always mount your local font directory into `/usr/share/fonts/external/`. 

If you just want to use (or snoop around in) the image without mounting external folders, you can run this image by using:

    docker run -t -i thomasweise/texlive

Another example for the use of the syntax for directly passing in a single command for execution is compiling a thesis based on the [USTC thesis template](https://github.com/ustctug/ustcthesis). Such documents can be compiled using `make`, so you could do something like

    docker run -v /path/to/my/thesis/:/doc/ -v /path/to/fonts/:/usr/share/fonts/external/ -t -i thomasweise/texlive make

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
- `filterPdfExact.sh <document>` does the same as `filderPdf.sh`, except that it does not re-encode the included images.
- `sudo` is a pseudo-`sudo` command: Inside a Docker container, we don't need `sudo`. However, if you have a script or something that calls plain `sudo` (without additional arguments) just with a to-be-sudoed command, this script will emulate a `sudo`. By doing nothing.
- `downscalePdf.sh <document> {resolution}` makes a pdf document smaller by downscaling all included images (to the specified resolution).
- `findNonASCIIChars.sh <document>` finds non-ASCII characters in a document. In `.tex` documents, such characters may pose problems.

## 4. License

This image is licensed under the GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007, which you can find in file [LICENSE.md](https://github.com/thomasWeise/docker-texlive/blob/master/LICENSE.md). The license applies to the way the image is built, while the software components inside the image are under the respective licenses chosen by their respective copyright holders.

## 5. Contact

If you have any questions or suggestions, please contact [Thomas Weise](mailto:tweise@hfuu.edu.cn) of the [Institute of Applied Optimization](http://iao.hfuu.edu.cn) of [Hefei University](http://www.hfuu.edu.cn) in Hefei, Anhui, China.