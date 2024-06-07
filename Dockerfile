FROM mlan/asterisk:mini

# Install dependencies
RUN apk update && apk add --no-cache \
    build-base \
    linux-headers \
    libxml2-dev \
    ncurses-dev \
    util-linux-dev \
    jansson-dev \
    sqlite-dev \
    git \
    autoconf \
    automake \
    libtool \
    bash \
    unixodbc \
    unixodbc-dev

# Clone, build, and install chan_sccp
RUN git clone https://github.com/chan-sccp/chan-sccp.git /usr/src/chan-sccp && \
    cd /usr/src/chan-sccp && \
    ./configure --with-asterisk=/usr && \
    make && \
    make install
