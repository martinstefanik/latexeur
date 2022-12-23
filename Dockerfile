FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TEXLIVE_INSTALL_ENV_NOCHECK=1
ENV TEXDIR=/usr/local/texlive/latexeur
ARG REPOSITORY=http://mirror.ctan.org/systems/texlive/tlnet

COPY . /latexeur
WORKDIR /latexeur

RUN adduser --disabled-password --gecos '' latexeur \
    && chown -R latexeur:latexeur /latexeur

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        fontconfig \
        libfontconfig1 \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN if [ ${REPOSITORY:-1} = / ]; then \
        wget "${REPOSITORY}"install-tl-unx.tar.gz; \
    else \
        wget "${REPOSITORY}"/install-tl-unx.tar.gz; \
    fi; \
    mkdir tmp; \
    tar -xvf install-tl-unx.tar.gz -C tmp --strip-components=1; \
    echo "selected_scheme scheme-basic" >> tmp/texlive.profile; \
    ./tmp/install-tl \
        -repository "${REPOSITORY}" \
        -profile tmp/texlive.profile \
        -texdir "${TEXDIR}"; \
    if [ ! -z "$(ls -A fonts)" ]; then \
        cp -r fonts/* /usr/local/share/fonts; \
        fc-cache -fv; \
    fi; \
    mkdir -p /home/latexeur/texmf/tex/latex; \
    if [ ! -z "$(ls -A classes)" ]; then \
        cp -t /home/latexeur/texmf/tex/latex classes/*; \
    fi; \
    if [ ! -z "$(ls -A packages)" ]; then \
        cp -t /home/latexeur/texmf/tex/latex packages/*; \
    fi; \
    chown -R latexeur:latexeur /home/latexeur/texmf; \
    rm -rf /latexeur/tmp; \
    ln -s "${TEXDIR}"/bin/x86_64-linux/latexmk /bin/latexmk; \
    ln -s "${TEXDIR}"/bin/x86_64-linux/latexmk /usr/bin/latexmk

ENV PATH="${TEXDIR}/bin/x86_64-linux:${PATH}"

RUN cat packages.txt | xargs tlmgr install; \
    rm -rf /latexeur/*

USER latexeur
