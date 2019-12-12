#!/bin/bash
declare -a quasselcore_args

# Specify the directory holding configuration files, the SQlite database and the SSL certificate.
# format: path
quasselcore_args+=(
  --configdir "${CONFIG_DIR}"
)
  
# The address(es) quasselcore will listen on.
# format: <address>[,<address>[,...]]
if [[ "${QUASSEL_PORT}" != "4242" ]]; then
  quasselcore_args+=(
    --port "${QUASSEL_PORT}"
  )
fi
  
# The port quasselcore will listen at.
# format: port
if [[ "${QUASSEL_LISTEN}" != "::,0.0.0.0" ]]; then
  quasselcore_args+=(
    --listen "${QUASSEL_LISTEN}"
  )
fi

# Don't restore last core's state.
if [[ "${NORESTORE}" == "true" ]]; then
  quasselcore_args+=(
    --norestore
  )
fi

# Load configuration from environment variables.
if [[ "${CONFIG_FROM_ENVIRONMENT}" == "true" ]]; then
  quasselcore_args+=(
    --config-from-environment
  )
fi

# Use users' quasselcore username as ident reply. Ignores each user's configured ident setting.
if [[ "${STRICT_IDENT}" == "true" ]]; then
  quasselcore_args+=(
    --strict-ident
  )
fi

# Enable internal ident daemon.
if [[ "${IDENT_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --ident-daemon
  )
fi

# The address(es) quasselcore will listen on for ident requests. Same format as --listen.
# format: <address>[,<address>[,...]]
if [[ "${IDENT_LISTEN}" != "::1,127.0.0.1" ]]; then
  quasselcore_args+=(
    --ident-listen "${IDENT_LISTEN}"
  )
fi
  
# The port quasselcore will listen at for ident requests. Only meaningful with --ident-daemon.
# format: port
if [[ "${IDENT_PORT}" != "10113" ]]; then
  quasselcore_args+=(
    --ident-port "${IDENT_PORT}"
  )
fi

# Enable oidentd integration. In most cases you should also enable --strict-ident.
if [[ "${OIDENTD_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --oidentd
  )
fi

# Set path to oidentd configuration file.
# format: file
if [[ ! -z "${OIDENTD_CONFIG_FILE}" ]]; then
  quasselcore_args+=(
    --oidentd-conffile "${OIDENTD_CONFIG_FILE}"
  )
fi

# Require SSL for remote (non-loopback) client connections.
if [[ "${SSL_REQUIRED}" == "true" ]]; then
  quasselcore_args+=(
    --require-ssl
  )
fi

# Specify the path to the SSL certificate.
# format: path
if [[ ! -z "${SSL_CERT_FILE}" ]]; then
  quasselcore_args+=(
    --ssl-cert "${SSL_CERT_FILE}"
  )
fi

# Specify the path to the SSL key.
# format: path
if [[ ! -z "${SSL_KEY_FILE}" ]]; then
  quasselcore_args+=(
    --ssl-key "${SSL_KEY_FILE}"
  )
fi

# Enable metrics API.
if [[ "${METRICS_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --metrics-daemon
  )
fi

# The address(es) quasselcore will listen on for metrics requests. Same format as --listen.
# format: <address>[,<address>[,...]]
if [[ "${METRICS_LISTEN}" != "::1,127.0.0.1" ]]; then
  quasselcore_args+=(
    --metrics-listen "${METRICS_LISTEN}"
  )
fi

# The port quasselcore will listen at for metrics requests. Only meaningful with --metrics-daemon.
# format: port
if [[ "${METRICS_PORT}" != "9558" ]]; then
  quasselcore_args+=(
    --metrics-port "${METRICS_PORT}"
  )
fi

# Supports one of Debug|Info|Warning|Error; default is Info.
# format: level
if [[ "${LOGLEVEL}" != "Info" ]]; then
  quasselcore_args+=(
    --loglevel "${LOGLEVEL}"
  )
fi

# Enable logging of all SQL queries to debug log, also sets --loglevel Debug automatically
if [[ "${DEBUG_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --debug
  )
fi

# Enable logging of all raw IRC messages to debug log, including passwords!  In most cases you should also set --loglevel Debug
if [[ "${DEBUG_IRC_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --debug-irc
  )
fi

# Limit raw IRC logging to this network ID.  Implies --debug-irc
# format: database_network_ID
if [[ ! -z "${DEBUG_IRC_ID}" ]]; then
  quasselcore_args+=(
    --debug-irc-id "${DEBUG_IRC_ID}"
  )
fi

# Enable logging of all parsed IRC messages to debug log, including passwords!  In most cases you should also set --loglevel Debug
if [[ "${DEBUG_IRC_PARSED_ENABLED}" == "true" ]]; then
  quasselcore_args+=(
    --debug-irc-parsed
  )
fi

# Limit parsed IRC logging to this network ID.  Implies --debug-irc-parsed
# format: database_network_ID
if [[ ! -z "${DEBUG_IRC_PARSED_ID}" ]]; then
  quasselcore_args+=(
    --debug-irc-parsed-id "${DEBUG_IRC_PARSED_ID}"
  )
fi

exec quasselcore "${quasselcore_args[@]}" "$@"
