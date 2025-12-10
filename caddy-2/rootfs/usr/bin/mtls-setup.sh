#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Home Assistant Add-on: Caddy 2
#
# mTLS Certificate Generation and Management
# ------------------------------------------------------------------------------

setup_mtls() {
    bashio::log.trace "${FUNCNAME[0]}"

    # Check if mTLS is enabled
    if ! bashio::config.true 'mtls.enabled'; then
        bashio::log.info "mTLS is not enabled"
        return 0
    fi

    bashio::log.info "Setting up mTLS certificates..."

    # Set certificate directory
    MTLS_DIR="/ssl/mtls"
    mkdir -p "${MTLS_DIR}"

    # Export mTLS directory for use in Caddyfile
    export MTLS_DIR

    # CA Certificate
    setup_ca_certificate

    # Server Certificate
    setup_server_certificate

    # Client Certificates
    setup_client_certificates

    bashio::log.info "mTLS setup completed successfully"
}

setup_ca_certificate() {
    bashio::log.trace "${FUNCNAME[0]}"
    bashio::log.info "Setting up CA certificate..."

    CA_KEY="${MTLS_DIR}/mTLS-CA.key"
    CA_CERT="${MTLS_DIR}/mTLS-CA.crt"

    # Check if CA already exists and regeneration is not forced
    if bashio::fs.file_exists "${CA_CERT}" && ! bashio::config.true 'mtls.regenerate_ca'; then
        bashio::log.info "CA certificate already exists, skipping generation"
        return 0
    fi

    # Generate CA private key
    bashio::log.info "Generating CA private key..."
    openssl ecparam -name prime256v1 -genkey -noout -out "${CA_KEY}"

    # Get CA subject information
    CA_COUNTRY=$(bashio::config 'mtls.ca.country')
    CA_STATE=$(bashio::config 'mtls.ca.state')
    CA_LOCALITY=$(bashio::config 'mtls.ca.locality')
    CA_ORGANIZATION=$(bashio::config 'mtls.ca.organization')
    CA_OU=$(bashio::config 'mtls.ca.organizational_unit')
    CA_CN=$(bashio::config 'mtls.ca.common_name')
    CA_EMAIL=$(bashio::config 'mtls.ca.email')

    # Build subject string
    CA_SUBJECT="/C=${CA_COUNTRY}/ST=${CA_STATE}/L=${CA_LOCALITY}/O=${CA_ORGANIZATION}/OU=${CA_OU}/CN=${CA_CN}/emailAddress=${CA_EMAIL}"

    # Generate CA certificate
    bashio::log.info "Generating CA certificate..."
    openssl req -new -x509 -sha256 -key "${CA_KEY}" -out "${CA_CERT}" -days 36500 -subj "${CA_SUBJECT}"

    bashio::log.info "CA certificate generated successfully"
}

setup_server_certificate() {
    bashio::log.trace "${FUNCNAME[0]}"
    bashio::log.info "Setting up server certificate..."

    SERVER_KEY="${MTLS_DIR}/mTLS-server.key"
    SERVER_CSR="${MTLS_DIR}/mTLS-server.csr"
    SERVER_CERT="${MTLS_DIR}/mTLS-server.crt"
    CA_KEY="${MTLS_DIR}/mTLS-CA.key"
    CA_CERT="${MTLS_DIR}/mTLS-CA.crt"

    # Check if server cert already exists and regeneration is not forced
    if bashio::fs.file_exists "${SERVER_CERT}" && ! bashio::config.true 'mtls.regenerate_server'; then
        bashio::log.info "Server certificate already exists, skipping generation"
        return 0
    fi

    # Generate server private key
    bashio::log.info "Generating server private key..."
    openssl ecparam -name prime256v1 -genkey -noout -out "${SERVER_KEY}"

    # Get server subject information
    SERVER_COUNTRY=$(bashio::config 'mtls.server.country')
    SERVER_STATE=$(bashio::config 'mtls.server.state')
    SERVER_LOCALITY=$(bashio::config 'mtls.server.locality')
    SERVER_ORGANIZATION=$(bashio::config 'mtls.server.organization')
    SERVER_OU=$(bashio::config 'mtls.server.organizational_unit')
    SERVER_CN=$(bashio::config 'mtls.server.common_name')
    SERVER_EMAIL=$(bashio::config 'mtls.server.email')

    # Build subject string
    SERVER_SUBJECT="/C=${SERVER_COUNTRY}/ST=${SERVER_STATE}/L=${SERVER_LOCALITY}/O=${SERVER_ORGANIZATION}/OU=${SERVER_OU}/CN=${SERVER_CN}/emailAddress=${SERVER_EMAIL}"

    # Generate server CSR
    bashio::log.info "Generating server CSR..."
    openssl req -new -sha256 -key "${SERVER_KEY}" -out "${SERVER_CSR}" -subj "${SERVER_SUBJECT}"

    # Sign server certificate with CA
    bashio::log.info "Signing server certificate..."
    openssl x509 -req -in "${SERVER_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${SERVER_CERT}" -days 36500 -sha256

    # Export server certificate paths
    export MTLS_SERVER_CERT="${SERVER_CERT}"
    export MTLS_SERVER_KEY="${SERVER_KEY}"
    export MTLS_CA_CERT="${CA_CERT}"

    bashio::log.info "Server certificate generated successfully"
}

setup_client_certificates() {
    bashio::log.trace "${FUNCNAME[0]}"
    bashio::log.info "Setting up client certificates..."

    CA_KEY="${MTLS_DIR}/mTLS-CA.key"
    CA_CERT="${MTLS_DIR}/mTLS-CA.crt"

    # Get number of client certificates to generate
    CLIENT_COUNT=$(bashio::config 'mtls.clients|length')

    if [ "${CLIENT_COUNT}" -eq 0 ]; then
        bashio::log.info "No client certificates configured"
        return 0
    fi

    bashio::log.info "Generating ${CLIENT_COUNT} client certificate(s)..."

    # Loop through each client
    for i in $(seq 0 $((CLIENT_COUNT - 1))); do
        CLIENT_NAME=$(bashio::config "mtls.clients[${i}].name")

        bashio::log.info "Processing client certificate for: ${CLIENT_NAME}"

        CLIENT_KEY="${MTLS_DIR}/mTLS-client-${CLIENT_NAME}.key"
        CLIENT_CSR="${MTLS_DIR}/mTLS-client-${CLIENT_NAME}.csr"
        CLIENT_CERT="${MTLS_DIR}/mTLS-client-${CLIENT_NAME}.crt"
        CLIENT_P12="${MTLS_DIR}/mTLS-client-${CLIENT_NAME}.p12"

        # Check if client cert already exists and regeneration is not forced
        if bashio::fs.file_exists "${CLIENT_CERT}" && ! bashio::config.true 'mtls.regenerate_clients'; then
            bashio::log.info "Client certificate for ${CLIENT_NAME} already exists, skipping"
            continue
        fi

        # Generate client private key
        bashio::log.info "Generating client private key for ${CLIENT_NAME}..."
        openssl ecparam -name prime256v1 -genkey -noout -out "${CLIENT_KEY}"

        # Get client subject information
        CLIENT_COUNTRY=$(bashio::config "mtls.clients[${i}].country")
        CLIENT_STATE=$(bashio::config "mtls.clients[${i}].state")
        CLIENT_LOCALITY=$(bashio::config "mtls.clients[${i}].locality")
        CLIENT_ORGANIZATION=$(bashio::config "mtls.clients[${i}].organization")
        CLIENT_OU=$(bashio::config "mtls.clients[${i}].organizational_unit")
        CLIENT_CN=$(bashio::config "mtls.clients[${i}].common_name")
        CLIENT_EMAIL=$(bashio::config "mtls.clients[${i}].email")

        # Build subject string
        CLIENT_SUBJECT="/C=${CLIENT_COUNTRY}/ST=${CLIENT_STATE}/L=${CLIENT_LOCALITY}/O=${CLIENT_ORGANIZATION}/OU=${CLIENT_OU}/CN=${CLIENT_CN}/emailAddress=${CLIENT_EMAIL}"

        # Generate client CSR
        bashio::log.info "Generating client CSR for ${CLIENT_NAME}..."
        openssl req -new -sha256 -key "${CLIENT_KEY}" -out "${CLIENT_CSR}" -subj "${CLIENT_SUBJECT}"

        # Sign client certificate with CA
        bashio::log.info "Signing client certificate for ${CLIENT_NAME}..."
        openssl x509 -req -in "${CLIENT_CSR}" -CA "${CA_CERT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${CLIENT_CERT}" -days 36500 -sha256

        # Get P12 password
        CLIENT_PASSWORD=$(bashio::config "mtls.clients[${i}].p12_password")

        # Generate P12 file
        bashio::log.info "Generating P12 file for ${CLIENT_NAME}..."
        if [ -n "${CLIENT_PASSWORD}" ]; then
            openssl pkcs12 -export -out "${CLIENT_P12}" -inkey "${CLIENT_KEY}" -in "${CLIENT_CERT}" -passout "pass:${CLIENT_PASSWORD}"
        else
            bashio::log.warning "No P12 password set for ${CLIENT_NAME}, using empty password"
            openssl pkcs12 -export -out "${CLIENT_P12}" -inkey "${CLIENT_KEY}" -in "${CLIENT_CERT}" -passout pass:
        fi

        bashio::log.info "Client certificate for ${CLIENT_NAME} generated successfully"
        bashio::log.info "Client P12 file: ${CLIENT_P12}"
    done

    bashio::log.info "All client certificates generated successfully"
}

# Run mTLS setup
setup_mtls
