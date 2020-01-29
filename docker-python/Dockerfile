FROM python:3.7-alpine3.10

RUN apk add --no-cache \
            --virtual=.build-dependencies \
            g++ gfortran file binutils \
            musl-dev python3-dev cython openblas-dev \
            libstdc++ openblas \
            build-base \
            cmake \
            bash \
            boost-dev \
            autoconf \
            zlib-dev \
            flex \
            bison \
            make \
            g++  \
            gfortran \
            file \
            binutils \
            && ln -s locale.h /usr/include/xlocale.h

# install python basis
RUN pip install --upgrade pip \
    && pip install --no-cache-dir six pytest numpy cython

# this must run separately!
RUN pip install --no-cache-dir pandas
RUN pip install --no-cache-dir scipy
RUN pip install --no-cache-dir scikit-learn

# install pyarrow, new version 0.15.1 does not work!!!
ARG ARROW_VERSION=0.14.1
ARG ARROW_SHA1=aea422382c92c90fc96c2e16338f141c
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
    PARQUET_HOME=/usr/local

#Download and build apache-arrow
RUN mkdir /arrow \
    && apk add --no-cache curl \
    && curl -o /tmp/apache-arrow.tar.gz -SL https://github.com/apache/arrow/archive/apache-arrow-${ARROW_VERSION}.tar.gz \
    && echo "$ARROW_SHA1 *apache-arrow.tar.gz" | sha1sum /tmp/apache-arrow.tar.gz \
    && tar -xvf /tmp/apache-arrow.tar.gz -C /arrow --strip-components 1 \
    && mkdir -p /arrow/cpp/build \
    && cd /arrow/cpp/build \
    && cmake -DCMAKE_BUILD_TYPE=$ARROW_BUILD_TYPE \
          -DCMAKE_INSTALL_LIBDIR=lib \
          -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
          -DARROW_PARQUET=on \
          -DARROW_PYTHON=on \
          -DARROW_PLASMA=on \
          -DARROW_BUILD_TESTS=OFF \
          .. \
    && make -j$(nproc) \
    && make install \
    && cd /arrow/python \
    && python setup.py build_ext --build-type=$ARROW_BUILD_TYPE --with-parquet \
    && python setup.py install \
    && rm -rf /arrow /tmp/apache-arrow.tar.gz

