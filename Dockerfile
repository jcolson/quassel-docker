# development image
ARG BASE=alpine:latest
FROM $BASE AS builder

# install development dependencies
RUN apk add --no-cache \
  make \
  cmake \
  curl \
  dbus-dev \
  g++ \
  gcc \
  git \
  libressl \
  libressl-dev \
  openldap-dev \
  ninja \
  paxmark \
  boost-dev \
  qt5-qtbase-dev \
  qt5-qtbase-postgresql \
  qt5-qtbase-sqlite \
  qca-dev

# ARG QUASSEL_VERSION="0.13.1"
ARG QUASSEL_BRANCH="20201013master+column"
# ARG QUASSEL_BRANCH="0.13"
ARG QUASSEL_REPO="https://github.com/jcolson/quassel"
# ARG QUASSEL_REPO="https://github.com/quassel/quassel"

RUN if [ "$QUASSEL_BRANCH" = "0.13" ] || [ "$QUASSEL_BRANCH" = "20201013master+column" ]; then \
      apk add --no-cache qt5-qtscript-dev; \
    fi

# setup repo 
RUN mkdir /quassel && \
    git clone -b "$QUASSEL_BRANCH" --single-branch "$QUASSEL_REPO" /quassel/src && \
    cd /quassel/src && \
    if [ ! -z "$QUASSEL_VERSION" ]; then \
      git checkout $QUASSEL_VERSION; \
    fi

# generate build files       -GNinja \
RUN mkdir /quassel/build && \
    cd /quassel/build && \
    CXXFLAGS="-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -fPIE -pie -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now" \
    cmake \
      -DCMAKE_INSTALL_PREFIX=/quassel/install \
      -DCMAKE_BUILD_TYPE="Release" \
      -DUSE_QT5=ON \
      -DWITH_KDE=OFF \
      -DWANT_QTCLIENT=OFF \
      -DWANT_CORE=ON \
      -DWANT_MONO=OFF \
      -DWITH_CRYPT=ON \
      /quassel/src

# build binaries - ninja
RUN cd /quassel/build && \
    make && \
    make install && \
    paxmark -m /quassel/install/bin/quasselcore
    
# generate empty directory so docker doesn’t break
RUN mkdir -p /quassel/install/lib_fix_docker_copy

# runtime image
FROM $BASE

# install runtime dependencies
RUN apk add --no-cache \
  bash \
  boost \
  libressl \
  libldap \
  qt5-qtbase \
  qt5-qtbase-postgresql \
  qt5-qtbase-sqlite \
  qca-dev

# ARG QUASSEL_VERSION="0.13.1"
ARG QUASSEL_BRANCH="bug_ircserver_password_column"
ARG QUASSEL_REPO="https://github.com/jcolson/quassel"

RUN if [ "$QUASSEL_BRANCH" = "0.13" ]; then \
      apk add --no-cache qt5-qtscript; \
    fi

# copy binaries
COPY --from=builder /quassel/install/bin /usr/bin/
COPY --from=builder /quassel/install/lib* /usr/lib/

# setup user environment
RUN addgroup -g 1000 -S quassel && \
    adduser -S -G quassel -u 1000 -s /bin/sh -h /config quassel
USER quassel
VOLUME /config

# expose ports
EXPOSE 4242/tcp
EXPOSE 10113/tcp

# Specify the directory holding configuration files, the SQlite database and the SSL certificate.
ENV CONFIG_DIR="/config"

# The address(es) quasselcore will listen on.
ENV QUASSEL_LISTEN="::,0.0.0.0"
# The port quasselcore will listen at.
ENV QUASSEL_PORT="4242"

# Don't restore last core's state.
ENV NORESTORE="false"

# Use users' quasselcore username as ident reply. Ignores each user's configured ident setting.
ENV STRICT_IDENT="false"

# Enable internal ident daemon.
ENV IDENT_ENABLED="false"
# The address(es) quasselcore will listen on for ident requests. Same format as --listen.
ENV IDENT_LISTEN="::1,127.0.0.1"
# The port quasselcore will listen at for ident requests. Only meaningful with --ident-daemon.
ENV IDENT_PORT="10113"

# Enable oidentd integration. In most cases you should also enable --strict-ident.
ENV OIDENTD_ENABLED="false"
# Set path to oidentd configuration file.
ENV OIDENTD_CONF_FILE=""

# Require SSL for remote (non-loopback) client connections.
ENV SSL_REQUIRED="false"
# Specify the path to the SSL certificate.
ENV SSL_CERT_FILE=""
# Specify the path to the SSL key.
ENV SSL_KEY_FILE=""

# Enable metrics API.
ENV METRICS_ENABLED="false"
# The address(es) quasselcore will listen on for metrics requests. Same format as --listen.
ENV METRICS_LISTEN="::1,127.0.0.1"
# The port quasselcore will listen at for metrics requests. Only meaningful with --metrics-daemon.
ENV METRICS_PORT="9558"

# Supports one of Debug|Info|Warning|Error; default is Info.
ENV LOGLEVEL="Info"

# Enable logging of all SQL queries to debug log, also sets --loglevel Debug automatically
ENV DEBUG_ENABLED="false"
# Enable logging of all raw IRC messages to debug log, including passwords!  In most cases you should also set --loglevel Debug
ENV DEBUG_IRC_ENABLED="false"
# Limit raw IRC logging to this network ID.  Implies --debug-irc
ENV DEBUG_IRC_ID=""
# Enable logging of all parsed IRC messages to debug log, including passwords!  In most cases you should also set --loglevel Debug
ENV DEBUG_IRC_PARSED_ENABLED="false"
# Limit parsed IRC logging to this network ID.  Implies --debug-irc-parsed
ENV DEBUG_IRC_PARSED_ID=""

# Load configuration from environment variables.
ENV CONFIG_FROM_ENVIRONMENT="false"

# Specify the database backend.  Allowed values: SQLite or PostgreSQL
ENV DB_BACKEND="SQLite"
# If the backend is PostgreSQL, specify the database user username
ENV DB_PGSQL_USERNAME="quassel"
# If the backend is PostgreSQL, specify the database user password
ENV DB_PGSQL_PASSWORD=""
# If the backend is PostgreSQL, specify the hostname of the database
ENV DB_PGSQL_HOSTNAME="localhost"
# If the backend is PostgreSQL, specify the port of the database
ENV DB_PGSQL_PORT="5432"
# If the backend is PostgreSQL, specify the database of the PostgreSQL cluster
ENV DB_PGSQL_DATABASE="quassel"

# Specify the authenticator backend.  Allowed values: Database or Ldap
ENV AUTH_AUTHENTICATOR="Database"
# If the authenticator is Ldap, specify the hostname of the directory server
ENV AUTH_LDAP_HOSTNAME="ldap://localhost"
# If the authenticator is Ldap, specify the port of the directory server
ENV AUTH_LDAP_PORT="389"
# If the authenticator is Ldap, specify the bind dn
ENV AUTH_LDAP_BIND_DN=""
# If the authenticator is Ldap, specify the bind password
ENV AUTH_LDAP_BIND_PASSWORD=""
# If the authenticator is Ldap, specify the base dn
ENV AUTH_LDAP_BASE_DN=""
# If the authenticator is Ldap, specify the filter query
ENV AUTH_LDAP_FILTER=""
# If the authenticator is Ldap, specify the attribute to be used as userid
ENV AUTH_LDAP_UID_ATTRIBUTE="uid"

ADD src/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
