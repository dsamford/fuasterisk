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
    asterisk-dev \
    curl \
    alsa-lib \
    alsa-plugins-pulse \
    alsa-utils \
    lua \
    libedit-dev \
    openssl-dev \
    wget

# Clone, build, and install chan_sccp
RUN git clone https://github.com/chan-sccp/chan-sccp.git /usr/src/chan-sccp && \
    cd /usr/src/chan-sccp && \
    ./configure --with-asterisk=/usr && \
    make && \
    make install

# Download and extract Asterisk source code
RUN curl -o /tmp/asterisk.tar.gz https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz && \
    mkdir -p /usr/src/asterisk && \
    tar -xzf /tmp/asterisk.tar.gz -C /usr/src/asterisk --strip-components=1

# Build and install additional modules
RUN cd /usr/src/asterisk && \
    ./configure && \
    make menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_APPS menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_CDR menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_CEL menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_CHANNELS menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_CODECS menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_FORMATS menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_FUNCS menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_PBX menuselect.makeopts && \
    menuselect/menuselect --disable-category MENUSELECT_RES menuselect.makeopts && \
    menuselect/menuselect --disable astdb2sqlite3 menuselect.makeopts && \
    menuselect/menuselect --enable res_odbc menuselect.makeopts && \
    menuselect/menuselect --enable res_config_odbc menuselect.makeopts && \
    menuselect/menuselect --enable res_resolver_unbound menuselect.makeopts && \
    menuselect/menuselect --enable res_hep menuselect.makeopts && \
    menuselect/menuselect --enable res_hep_rtcp menuselect.makeopts && \
    menuselect/menuselect --enable res_hep_pjsip menuselect.makeopts && \
    menuselect/menuselect --enable res_calendar menuselect.makeopts && \
    menuselect/menuselect --enable app_agent_pool menuselect.makeopts && \
    menuselect/menuselect --enable cdr_sqlite3_custom menuselect.makeopts && \
    menuselect/menuselect --enable cel_sqlite3_custom menuselect.makeopts && \
    menuselect/menuselect --enable cdr_manager menuselect.makeopts && \
    menuselect/menuselect --enable pbx_lua menuselect.makeopts && \
    menuselect/menuselect --enable res_http_media_cache menuselect.makeopts && \
    menuselect/menuselect --enable app_voicemail_imap menuselect.makeopts && \
    menuselect/menuselect --enable app_festival menuselect.makeopts && \
    menuselect/menuselect --enable pbx_config menuselect.makeopts && \
    menuselect/menuselect --enable pbx_ael menuselect.makeopts && \
    menuselect/menuselect --enable res_prometheus menuselect.makeopts && \
    make && \
    make install

# Create the directory and copy asterisk-scripts
RUN mkdir -p /asterisk_scripts
COPY ./asterisk-scripts/ /asterisk_scripts/

# Expose necessary ports
EXPOSE 5060/tcp 5061/tcp 5060/udp 2000/tcp 5038/tcp
EXPOSE 10000-20000/udp

# Start Asterisk in the foreground
CMD ["asterisk", "-f", "-U", "asterisk", "-G", "asterisk"]
