#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Caddy 2
#
# Launch Caddy
# ------------------------------------------------------------------------------
non_caddyfile_config() {
    bashio::log.trace "${FUNCNAME[0]}"

    export EMAIL=$(bashio::config 'non_caddyfile_config.email')
    export DOMAIN=$(bashio::config 'non_caddyfile_config.domain')
    export DESTINATION=$(bashio::config 'non_caddyfile_config.destination')
    export PORT=$(bashio::config 'non_caddyfile_config.port')
}

main() {
    bashio::log.trace "${FUNCNAME[0]}"

    declare name
    declare value
    ARGS=$(bashio::config 'args')

    # Load custom environment variables
    for var in $(bashio::config 'env_vars|keys'); do
        name=$(bashio::config "env_vars[${var}].name")
        value=$(bashio::config "env_vars[${var}].value")
        bashio::log.info "Setting ${name} to ${value}"
        export "${name}=${value}"
    done

    # Check for custom Caddy binary
    if bashio::config.has_value 'custom_binary_path'; then
        CADDY_PATH="$(bashio::config 'custom_binary_path')"
    else
        CADDY_PATH=/share/caddy/caddy
    fi
    if bashio::fs.file_exists "${CADDY_PATH}"; then
        bashio::log.info "Found custom Caddy at ${CADDY_PATH}"
    else
        CADDY_PATH=/usr/bin/caddy
        bashio::log.info "Use built-in Caddy"
    fi
    "${CADDY_PATH}" version
    
    # Check for existing Caddyfile
    if bashio::config.has_value 'config_path'; then
        CONFIG_PATH="$(bashio::config 'config_path')"
    else
        CONFIG_PATH=/share/caddy/Caddyfile
    fi
    if bashio::fs.file_exists "${CONFIG_PATH}"; then
        bashio::log.info "Caddyfile found at ${CONFIG_PATH}"
    else
        bashio::log.info "No Caddyfile found"
        bashio::log.info "Use non_caddyfile_config"
        CONFIG_PATH=/etc/caddy/Caddyfile
        non_caddyfile_config
    fi

    # Run Caddy
    "${CADDY_PATH}" run --config "${CONFIG_PATH}" ${ARGS}
}
main "$@"
