# Latexeur

An easily customizable, minimal TeX Live image for building TEX files. As opposed to installing a full TeX Live installation that is too large for many purposes, the image is built from the *minimal* TeX Live installation with the addition of commonly used packages.

## Building the image

The image can be built by executing the following command inside the project directory:

```bash
docker build --tag latexeur .
```

The image allows for configuring the CTAN mirror that should be used for the installation of TeX Live in case the default mirror is down or any other issue. This is done using the `REPOSITORY` build argument, which defaults to <https://mirror.foobar.to/CTAN/systems/texlive/tlnet>. The full list of CTAN mirrors can be found [here](https://ctan.org/mirrors?lang=en).

## Extensions

If the list of installed packages is not satisfactory for the user, it can be easily extended by adding more packages to `packages.txt`. Furthermore, your own custom classes, fonts, and packages can be easily added by placing the source files into the `fonts`, `classes`, and `packages` directories, respectively. Hidden files (dot files) in these directories are ignored.

For instance, one could build the application with Source Code Pro font by running:

```bash
wget https://www.fontsquirrel.com/fonts/download/source-code-pro.zip
unzip -d fonts source-code-pro.zip
docker build --tag latexeur
```

## Quickstart

Given a LaTeX document `trial.tex`, one can compile it as follows:

```bash
docker run \
    --rm \
    --user $(id -u):$(id -g) \
    --volume "$(pwd):/app" \
    xelatex-docker latexmk -xelatex trial.tex
```

This will ensure that all files generated by `latexmk` persist on the host after the container is (automatically) removed as well as that these files are owned by the current user on the host.

Note also that the quotation marks in the argument passed to the `--volume` option above are needed in case the name of the current working directory (obtained by `pwd`) contains uppercase letters or spaces.

The above can also be easily wrapped into a command line application, if necessary.

