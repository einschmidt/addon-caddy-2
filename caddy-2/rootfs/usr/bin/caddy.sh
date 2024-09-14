#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Caddy 2
#
# Launch Caddy
# ------------------------------------------------------------------------------
 

# Prepare Caddy function to set custom Caddy path and check for custom Caddy 
# binary at the specified path. If found, exports custom Caddy variables;
# otherwise, uses the built-in Caddy binary path.
# Finally, checks the Caddy version.
prepare_caddy() {
    bashio::log.info 'Prepare Caddy...'

    # Set custom Caddy path
    CUSTOM_CADDY_PATH="/config/caddy"

    # Check for custom Caddy binary at custom Caddy path
    bashio::log.info "Checking path: ${CUSTOM_CADDY_PATH}"
    if bashio::fs.file_exists "${CUSTOM_CADDY_PATH}"; then
        bashio::log.info "Found custom Caddy binary at ${CUSTOM_CADDY_PATH}"
        export CUSTOM_CADDY=true
        export CADDY_PATH="${CUSTOM_CADDY_PATH}"
    else
        bashio::log.info "Use built-in Caddy"
        export CUSTOM_CADDY=false
        export CADDY_PATH="/usr/bin/caddy"
    fi

    # Check caddy version
    "${CADDY_PATH}" version
}

# Upgrade Caddy function to upgrade Caddy to the latest version
caddy_upgrade() {
    bashio::log.info 'Upgrade Caddy...'

    if ! ${CUSTOM_CADDY}; then
        bashio::log.info "Cannot upgrade Caddy as no custom binary has been found"
        return 0
    elif [ "$(${CADDY_PATH} version | awk '{print $1}')" == "$(curl -sL https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.tag_name')" ]; then
        bashio::log.info "Custom Caddy uses the latest version"
        return 0
    else
        bashio::log.info "Initiate upgrade"
        "${CADDY_PATH}" upgrade
    fi
}

prepare_caddyfile() {
    bashio::log.info 'Prepare Caddyfile...'

    # Set custom Caddyfile path
    CUSTOM_CADDYFILE_PATH="/config/Caddyfile"
    
    # Check for existing Caddyfile
    if bashio::fs.file_exists "${CUSTOM_CADDYFILE_PATH}"; then
        bashio::log.info "Caddyfile found at ${CUSTOM_CADDYFILE_PATH}"
        export CONFIG_PATH=${CUSTOM_CADDYFILE_PATH}
        export CADDYFILE=true
    else
        bashio::log.info "No Caddyfile found"
        bashio::log.info "Use non_caddyfile_config"
        export CONFIG_PATH=/etc/caddy/Caddyfile
        export CADDYFILE=false

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

caddy_fmt() {
    bashio::log.info 'Format Caddyfile...'

    if ! ${CADDYFILE}; then
        bashio::log.info "No Caddyfile found"
        return 0
    fi

    if [ -w ${CONFIG_PATH} ]; then
        bashio::log.info "Overwrite Caddyfile"
        "${CADDY_PATH}" fmt --overwrite ${CONFIG_PATH}
    else
        bashio::log.info "Caddyfile has been found but is not writable"
    fi
}

main() {
    bashio::log.trace "${FUNCNAME[0]}"

    declare name
    declare value
    declare -a args=()

    # Load command line arguments
    for arg in $(bashio::config 'args|keys'); do
        # shellcheck disable=SC2207
        args+=( $(bashio::config "args[${arg}]") )
    done

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

    # Format Caddyfile
    if bashio::config.true 'caddy_fmt'; then
        caddy_fmt
    fi

    # Run Caddy
    bashio::log.info "Run Caddy..."
    bashio::log.debug "'${CADDY_PATH}' run --config '${CONFIG_PATH}' '${args[*]}'"
    "${CADDY_PATH}" run --config "${CONFIG_PATH}" "${args[@]}"
}
main "$@"
