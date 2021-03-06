ARG BASE_VERSION=3.8.6-alpine3.12
FROM python:${BASE_VERSION}

# set version label
ARG MYLAR_COMMIT=v0.4.6
LABEL version ${BASE_VERSION}_${MYLAR_COMMIT}

RUN \
echo "**** install system packages ****" && \
 apk add --no-cache \
 git \
 # cfscrape dependecies
 nodejs \
 # unrar-cffi & Pillow dependencies
 build-base \
 # unar-cffi dependencies
 libffi-dev \
 # Pillow dependencies
 zlib-dev \
 jpeg-dev

# It might be better to check out release tags than python3-dev HEAD.
# For development work I reccomend mounting a full git repo from the
# docker host over /app/mylar.
RUN echo "**** install app ****" && \
 git config --global advice.detachedHead false && \
 git clone https://github.com/mylar3/mylar3.git --depth 1 --branch ${MYLAR_COMMIT} --single-branch /app/mylar

RUN echo "**** install requirements ****" && \
 pip3 install --no-cache-dir -U -r /app/mylar/requirements.txt && \
 rm -rf ~/.cache/pip/*

# TODO image could be further slimmed by moving python wheel building into a
# build image and copying the results to the final image.

# ports and volumes
VOLUME /config /comics /downloads
EXPOSE 8090
CMD ["python3", "/app/mylar/Mylar.py", "--nolaunch", "--quiet", "--datadir", "/config/mylar"]
