FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:mamarley/quassel && \
    apt-get update && \
    apt-get install -y quassel-core libqt5sql5-psql

EXPOSE 4242/tcp

ENV DB_BACKEND="SQLite"
ENV AUTH_AUTHENTICATOR="Database"
ENV DB_PGSQL_USERNAME="quassel"
ENV DB_PGSQL_PASSWORD=""
ENV DB_PGSQL_HOSTNAME="localhost"
ENV DB_PGSQL_PORT="5432"
ENV DB_PGSQL_DATABASE="quassel"
ENV AUTH_LDAP_HOSTNAME="ldap://localhost"
ENV AUTH_LDAP_PORT="389"
ENV AUTH_LDAP_BIND_DN=""
ENV AUTH_LDAP_BIND_PASSWORD=""
ENV AUTH_LDAP_BASE_DN=""
ENV AUTH_LDAP_FILTER=""
ENV AUTH_LDAP_UID_ATTRIBUTE="uid"

ENTRYPOINT ["quasselcore", "--config-from-environment"]
