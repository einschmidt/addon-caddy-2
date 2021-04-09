#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Caddy 2
#
# Launch Caddy
# ------------------------------------------------------------------------------
non_caddyfile_config() {
    bashio::log.trace "${FUNCNAME[0]}"

    EMAIL=$(bashio::config 'non_caddyfile_config.email')
    DOMAIN=$(bashio::config 'non_caddyfile_config.domain')
    DESTINATION=$(bashio::config 'non_caddyfile_config.destination')
    PORT=$(bashio::config 'non_caddyfile_config.port')
    
    export EMAIL
    export DOMAIN
    export DESTINATION
    export PORT
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

    # Check for config path config
    if bashio::config.has_value 'config_path'; then
        bashio::log.debug "Set custom Caddy config path"
        CONFIG_PATH="$(bashio::config 'config_path')"
    else
        CONFIG_PATH=/share/caddy/Caddyfile
    fi
    
    # Check for existing Caddyfile
    if bashio::fs.file_exists "${CONFIG_PATH}"; then
        bashio::log.info "Caddyfile found at ${CONFIG_PATH}"
    else
        bashio::log.info "No Caddyfile found"
        bashio::log.info "Use non_caddyfile_config"
        CONFIG_PATH=/etc/caddy/Caddyfile
        non_caddyfile_config
    fi

    # Format Caddyfile
    # bashio::log.info "Format Caddyfile"
    # "${CADDY_PATH}" fmt "${CONFIG_PATH}"

    # Run Caddy
    bashio::log.info "Run Caddy"
    bashio::log.debug "'${CADDY_PATH}' run --config '${CONFIG_PATH}' '${ARGS}'"
    "${CADDY_PATH}" run --config "${CONFIG_PATH}" "${ARGS}"
}
main "$@"
