#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Caddy 2
#
# Launch Caddy
# ------------------------------------------------------------------------------
prepare_caddy() {
    bashio::log.info 'Prepare Caddy...'

    # Check for custom Caddy binary path config
    if bashio::config.has_value 'custom_binary_path'; then
        bashio::log.debug "Set custom Caddy binary path"
        export CADDY_PATH="$(bashio::config 'custom_binary_path')"
    else
        export CADDY_PATH="/share/caddy/caddy"
    fi

    # Check for custom Caddy binary at Caddy path
    if bashio::fs.file_exists "${CADDY_PATH}"; then
        bashio::log.info "Found custom Caddy at ${CADDY_PATH}"
        export CUSTOM_CADDY=true
    else
        export CUSTOM_CADDY=false
        export CADDY_PATH="/usr/bin/caddy"
        bashio::log.info "Use built-in Caddy"
    fi

    # Check caddy version
    "${CADDY_PATH}" version
}

caddy_upgrade() {
    bashio::log.info 'Upgrade Caddy...'

    if ! ${CUSTOM_CADDY}; then
        bashio::log.info "Cannot upgrade Caddy as no custom binary has been found"
        return 0
    fi

    if [ -w ${CADDY_PATH} ]; then
        bashio::log.info "Initiate upgrade"
        "${CADDY_PATH}" upgrade
    else
        bashio::log.info "Custom Caddy has been found but is not writable"
    fi
}

prepare_caddyfile() {
    bashio::log.info 'Prepare Caddyfile...'

    # Check for config path config
    if bashio::config.has_value 'config_path'; then
        bashio::log.debug "Set custom Caddyfile path"
        export CONFIG_PATH="$(bashio::config 'config_path')"
    else
        export CONFIG_PATH="/share/caddy/Caddyfile"
    fi
    
    # Check for existing Caddyfile
    if bashio::fs.file_exists "${CONFIG_PATH}"; then
        bashio::log.info "Caddyfile found at ${CONFIG_PATH}"
    else
        bashio::log.info "No Caddyfile found"
        bashio::log.info "Use non_caddyfile_config"
        export CONFIG_PATH=/etc/caddy/Caddyfile
        non_caddyfile_config
    fi
}

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

    # Format Caddyfile
    # bashio::log.info "Format Caddyfile"
    # "${CADDY_PATH}" fmt "${CONFIG_PATH}"

    # Prepare Caddy
    prepare_caddy

    # Upgrade Caddy
    if bashio::config.true 'caddy_upgrade'; then
        caddy_upgrade
    fi

    # Prepare Caddyfile
    prepare_caddyfile

    # Run Caddy
    bashio::log.info "Run Caddy..."
    bashio::log.debug "'${CADDY_PATH}' run --config '${CONFIG_PATH}' '${ARGS}'"
    "${CADDY_PATH}" run --config "${CONFIG_PATH}" "${ARGS}"
}
main "$@"
