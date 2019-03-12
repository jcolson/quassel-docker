# Dockerimage for Quasselcore

## Stateful usage (with UI Wizard)

To use Quassel statefully (which allows you to configure the core on first use)
run it with `--entrypoint=/usr/bin/quasselcore` and make sure to include
`--configdir /quassel` as argument.

If you use the core in this mode, you’ll have to make sure `/quassel` is stored
on a volume.

## Stateless usage

By default, the core will be run in stateless mode, where it needs to be
configured through environment arguments.

`DB_BACKEND` defines the backend used for the database, this can be `SQLite` or
`PostgreSQL`. In case `SQLite` is used, the database will be stored in
`/root/.config/quassel-irc.org/quassel-storage.sqlite`. If `PostgreSQL` is used
instead, these variables determine the connection details: `DB_PGSQL_USERNAME`,
`DB_PGSQL_PASSWORD`, `DB_PGSQL_HOSTNAME`, `DB_PGSQL_PORT`, `DB_PGSQL_DATABASE`.

`AUTH_AUTHENTICATOR` defines the backend used for authentication, this can be
`Database` or `LDAP`. In case `LDAP` is used, the following environment
variables determine the connection details: `AUTH_LDAP_HOSTNAME`,
`AUTH_LDAP_PORT`, `AUTH_LDAP_BIND_DN`, `AUTH_LDAP_BIND_PASSWORD`,
`AUTH_LDAP_BASE_DN`, `AUTH_LDAP_FILTER`, `AUTH_LDAP_UID_ATTRIBUTE`.

## SSL

You can use the core with SSL, in this case you should either put a
`quasselCert.pem` file with the full certificate chain and private key into
the `/quassel` volume, or you can use the `--ssl-cert` and `--ssl-key`
arguments to use separate key and certificate.

## Ports

Per default, the container will listen on the port 4242 for connections.
This can be configured with `--port` and `--listen`.

If the `--ident-daemon` argument is passed, the ident daemon will additionally
listen on 10113. You can configure this with `--ident-port`.
