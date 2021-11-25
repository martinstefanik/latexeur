FROM debian:bullseye-slim

COPY . /app
WORKDIR /app

RUN adduser --disabled-password --gecos '' runner \
    && chown -R runner:runner /app

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        fontconfig \
        libfontconfig1 \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /install-tl-unx; \
    tar -xvf install-tl-2021-unx.tar.gz -C /install-tl-unx --strip-components=1; \
    echo "selected_scheme scheme-basic" >> /install-tl-unx/texlive.profile; \
    /install-tl-unx/install-tl -profile /install-tl-unx/texlive.profile; \
    if [ ! -z "$(ls fonts)" ]; then \
        cp -r fonts/* /usr/local/share/fonts; \
        fc-cache -fv; \
    fi; \
    mkdir -p /home/runner/texmf/tex/latex; \
    if [ ! -z "$(ls custom-classes)" ]; then \
        cp -t /home/runner/texmf/tex/latex custom-classes/*; \
    fi; \
    if [ ! -z "$(ls custom-packages)" ]; then \
        cp -t /home/runner/texmf/tex/latex custom-packages/*; \
    fi; \
    chown -R runner:runner /home/runner/texmf; \
    rm -r /install-tl-unx

ENV PATH="/usr/local/texlive/2021/bin/x86_64-linux:${PATH}"

RUN cat packages.txt | xargs tlmgr install; \
    rm -r /app/*

USER runner
