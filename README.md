# Dockerimage for Quasselcore

## Supported architectures

| Architecture | Tags                        |
| ------------ | --------------------------- |
| x86-64       | `0.13.1`, `latest`          |
| aarch64      | `0.13.1-aarch64`, `aarch64` |
| armhf        | `0.13.1-armhf`, `armhf`     |

## Configuration

### CONFIG_DIR

Specify the directory holding configuration files, the SQlite database and the
SSL certificate.

Default: `/config`

### QUASSEL_LISTEN

The address(es) quasselcore will listen on.

Default: `::,0.0.0.0`

### QUASSEL_PORT

The port quasselcore will listen at.

Default: `4242`

### NORESTORE

Don't restore last core's state.

Default: `false`

### STRICT_IDENT

Use users' quasselcore username as ident reply. Ignores each user's configured
ident setting.

Default: `false`

### IDENT_ENABLED

Enable internal ident daemon.

Default: `false`

### IDENT_LISTEN

The address(es) quasselcore will listen on for ident requests. Same format as
[QUASSEL_LISTEN](#quassel_listen). Only meaningful with
[IDENT_ENABLED](#ident_enabled).

Default: `::1,127.0.0.1`

### IDENT_PORT

The port quasselcore will listen at for ident requests. Only meaningful with
[IDENT_ENABLED](#ident_enabled).

Default: `10113`

### OIDENTD_ENABLED

Enable oidentd integration. In most cases you should also enable
[STRICT_IDENT](#strict_ident).

Default: `false`

### OIDENTD_CONF_FILE

Set path to oidentd configuration file.

### SSL_REQUIRED

Require SSL for remote (non-loopback) client connections.

Default: `false`

### SSL_CERT_FILE

Specify the path to the SSL certificate.

### SSL_KEY_FILE

Specify the path to the SSL key.

### METRICS_ENABLED

Enable metrics API.

Default: `false`

### METRICS_LISTEN

The address(es) quasselcore will listen on for metrics requests. Same format as
[QUASSEL_LISTEN](#quassel_listen).

Default: `::1,127.0.0.1`

### METRICS_PORT

The port quasselcore will listen at for metrics requests. Only meaningful with
[METRICS_ENABLED](#metrics_enabled).

Default: `9558`

### LOGLEVEL

Supports one of Debug|Info|Warning|Error; default is Info.

Default: `Info`

### DEBUG_ENABLED

Enable logging of all SQL queries to debug log, also sets [LOGLEVEL](#loglevel)
to `Debug` automatically

Default: `false`

### DEBUG_IRC_ENABLED

Enable logging of all raw IRC messages to debug log, including passwords!  
In most cases you should also set [LOGLEVEL](#loglevel) to Debug

Default: `false`

### DEBUG_IRC_ID

Limit raw IRC logging to this network ID.  Implies
[DEBUG_IRC_ENABLED](#debug_irc_enabled).

### DEBUG_IRC_PARSED_ENABLED

Enable logging of all parsed IRC messages to debug log, including passwords!  
In most cases you should also set [LOGLEVEL](#loglevel) to Debug

Default: `false`

### DEBUG_IRC_PARSED_ID

Limit parsed IRC logging to this network ID.  Implies
[DEBUG_IRC_PARSED_ENABLED](#debug_irc_parsed_enabled).

### CONFIG_FROM_ENVIRONMENT

Load configuration from environment variables.

Default: `false`

### DB_BACKEND

Specify the database backend.  Allowed values: SQLite or PostgreSQL

In case `SQLite` is used, the database will be stored by default in
`/config/quassel-storage.sqlite` (affected by [CONFIG_DIR](#config_dir))

Default: `SQLite`

### DB_PGSQL_USERNAME

If the backend is PostgreSQL, specify the database user username

Default: `quassel`

### DB_PGSQL_PASSWORD

If the backend is PostgreSQL, specify the database user password

### DB_PGSQL_HOSTNAME

If the backend is PostgreSQL, specify the hostname of the database

Default: `localhost`

### DB_PGSQL_PORT

If the backend is PostgreSQL, specify the port of the database

Default: `5432`

### DB_PGSQL_DATABASE

If the backend is PostgreSQL, specify the database of the PostgreSQL cluster

Default: `quassel`


### AUTH_AUTHENTICATOR

Specify the authenticator backend.  Allowed values: Database or Ldap

Default: `Database`

### AUTH_LDAP_HOSTNAME

If the authenticator is Ldap, specify the hostname of the directory server

Default: `ldap://localhost`

### AUTH_LDAP_PORT

If the authenticator is Ldap, specify the port of the directory server

Default: `389`

### AUTH_LDAP_BIND_DN

If the authenticator is Ldap, specify the bind dn

### AUTH_LDAP_BIND_PASSWORD

If the authenticator is Ldap, specify the bind password

### AUTH_LDAP_BASE_DN

If the authenticator is Ldap, specify the base dn

### AUTH_LDAP_FILTER

If the authenticator is Ldap, specify the filter query

### AUTH_LDAP_UID_ATTRIBUTE

If the authenticator is Ldap, specify the attribute to be used as userid

Default: `uid`


## Stateful usage (with UI Wizard)

By default, the core will be run in stateful mode.

If you use the core in this mode, you’ll have to make sure `/config` is stored
on a volume.

Example usage:

```bash
docker run \
  -v /path/to/quassel/volume:/config \
  k8r.eu/justjanne/quassel-docker:v0.13.1
```

## Example: Stateless usage (minimal)

```bash
docker run \
  -v /path/to/quassel/volume:/config \
  -e CONFIG_FROM_ENVIRONMENT=true \
  -e DB_BACKEND=SQLite \
  -e AUTH_AUTHENTICATOR=Database \
  k8r.eu/justjanne/quassel-docker:v0.13.1
```

## Example: Stateless usage (common)

```bash
docker run \
  -e STRICT_IDENT=true \
  -e IDENT_ENABLED=true \
  -e IDENT_PORT=10113 \
  -e IDENT_LISTEN=::,0.0.0.0 \
  -e SSL_REQUIRED=true \
  -e SSL_CERT_FILE=/tls.crt \
  -v /path/to/certificates/tls.crt:/tls.crt \
  -e SSL_KEY_FILE=/tls.key \
  -v /path/to/certificates/tls.key:/tls.key \
  -e CONFIG_FROM_ENVIRONMENT=true \
  -e DB_BACKEND=PostgreSQL \
  -e AUTH_AUTHENTICATOR=Database \
  -e DB_PGSQL_USERNAME=quassel \
  -e DB_PGSQL_PASSWORD=thesamecombinationasonmyluggage \
  -e DB_PGSQL_HOSTNAME=postgresql.default.svc.cluster.local \
  -e DB_PGSQL_PORT=5432 \
  -e DB_PGSQL_DATABASE=quassel \
  k8r.eu/justjanne/quassel-docker:v0.13.1
```

## SSL

You can use the core with SSL, in this case you should either put a
`quasselCert.pem` file with the full certificate chain and private key into
the `/config` volume, or you can use the [SSL_CERT_FILE](#ssl_cert_file) and
[SSL_KEY_FILE](#ssl_key_file) arguments to use separate key and certificate.

## Ports

Per default, the container will listen on the port 4242 for connections.
This can be configured with [QUASSEL_PORT](#quassel_port) and
[QUASSEL_LISTEN](#quassel_listen).

If [IDENT_ENABLED](#ident_enabled) is set, the ident daemon will additionally
listen on 10113. You can configure this with [IDENT_PORT](#ident_port).
This by default only listens on localhost, which obviously will cause issues
when used in a container like this, so make sure to configure
[IDENT_LISTEN](#ident_listen).  
You’ll also want to bind this to port 113 on the host, as IRC networks will
expect to find the ident daemon on that port.
