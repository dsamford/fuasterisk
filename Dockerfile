FROM mlan/asterisk:mini

# Install necessary packages
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
    unixodbc-dev \
    asterisk-dev

# Clone, build, and install chan_sccp
RUN git clone https://github.com/chan-sccp/chan-sccp.git /usr/src/chan-sccp && \
    cd /usr/src/chan-sccp && \
    ./configure --with-asterisk=/usr && \
    make && \
    make install

# Create the directory and copy asterisk-scripts
RUN mkdir -p /asterisk_scripts
COPY ./asterisk-scripts/ /asterisk_scripts/
