# mTLS Support for Caddy 2 Home Assistant Add-on

This fork adds comprehensive mutual TLS (mTLS) support to the Caddy 2 Home Assistant add-on, providing enhanced security through client certificate authentication.

## What's New

### mTLS Authentication
- **Automated Certificate Management**: Automatic generation of CA, server, and client certificates
- **Zero Manual Intervention**: All certificate operations are handled automatically
- **Multiple Client Support**: Generate certificates for multiple users/devices
- **PKCS#12 Export**: Client certificates exported in `.p12` format for easy import
- **Flexible Configuration**: All certificate details configurable via addon config
- **Certificate Persistence**: Certificates persist across addon restarts
- **Smart Regeneration**: Control when certificates are regenerated

## Features

### Certificate Chain Generation
The addon automatically generates a complete certificate chain:
1. **CA Certificate** - Root certificate authority
2. **Server Certificate** - Signed by CA, used by Caddy
3. **Client Certificates** - Signed by CA, distributed to users

### Configuration Options
All aspects of certificate generation are configurable:
- Subject information (Country, State, Locality, Organization, etc.)
- Common names for CA, server, and clients
- Email addresses
- P12 passwords for client certificates
- Regeneration flags for certificate renewal

### Security Features
- **ECC-based certificates** (prime256v1 curve) for enhanced security and performance
- **Long validity period** (36500 days) to avoid frequent renewals
- **SHA-256 signing** for cryptographic strength
- **Password-protected P12 files** for secure client certificate distribution
- **Require and verify mode** - Only authenticated clients can connect

## Quick Start

### Basic mTLS Configuration

```yaml
non_caddyfile_config:
  email: your@email.com
  domain: yourdomain.com
  destination: localhost
  port: 8123
mtls:
  enabled: true
  ca:
    common_name: My Home Assistant CA
    email: ca@yourdomain.com
  server:
    common_name: yourdomain.com
    email: server@yourdomain.com
  clients:
    - name: john_doe
      common_name: John Doe
      email: john@yourdomain.com
      p12_password: secure_password_here
log_level: info
```

### Accessing Client Certificates

Client certificates are stored in `/ssl/mtls/` and can be accessed via:
- SSH addon
- Samba addon
- File Editor addon

Files are named: `mTLS-client-{name}.p12`

### Installing Client Certificates

**Desktop Browsers (Chrome/Edge/Firefox):**
1. Import the `.p12` file via browser settings
2. Enter the configured password
3. Restart browser

**Mobile (iOS/Android):**
1. Transfer the `.p12` file to device
2. Import via Settings → Security
3. Enter password when prompted

## Implementation Details

### Files Modified/Added

1. **`rootfs/usr/bin/mtls-setup.sh`** (NEW)
   - Certificate generation script
   - Handles CA, server, and client certificate creation
   - Automatic P12 export

2. **`rootfs/usr/bin/caddy.sh`** (MODIFIED)
   - Calls mTLS setup before starting Caddy
   - Exports mTLS environment variables

3. **`rootfs/etc/caddy/Caddyfile`** (MODIFIED)
   - Conditional mTLS configuration
   - Uses environment variables for certificate paths

4. **`config.yaml`** (MODIFIED)
   - Added complete mTLS configuration schema
   - Support for multiple clients
   - Certificate regeneration options

5. **`DOCS.md`** (MODIFIED)
   - Comprehensive mTLS documentation
   - Setup examples
   - Troubleshooting guide

### Certificate Storage

All certificates are stored in `/ssl/mtls/`:
```
/ssl/mtls/
├── mTLS-CA.crt              # CA certificate
├── mTLS-CA.key              # CA private key
├── mTLS-server.crt          # Server certificate
├── mTLS-server.key          # Server private key
├── mTLS-server.csr          # Server CSR
├── mTLS-client-{name}.crt   # Client certificate
├── mTLS-client-{name}.key   # Client private key
├── mTLS-client-{name}.csr   # Client CSR
└── mTLS-client-{name}.p12   # Client PKCS#12 bundle
```

### Automation

The entire certificate generation process is fully automated:
1. On addon start, if mTLS is enabled
2. Check for existing certificates
3. Generate missing certificates
4. Respect regeneration flags
5. Export environment variables for Caddyfile
6. Start Caddy with mTLS configuration

## Configuration Reference

### mTLS Options

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `mtls.enabled` | bool | No | false | Enable/disable mTLS |
| `mtls.regenerate_ca` | bool | No | false | Force CA regeneration |
| `mtls.regenerate_server` | bool | No | false | Force server cert regeneration |
| `mtls.regenerate_clients` | bool | No | false | Force client cert regeneration |

### Certificate Subject Fields

Available for `mtls.ca.*`, `mtls.server.*`, and `mtls.clients[*].*`:

| Field | Type | Description |
|-------|------|-------------|
| `country` | string | Two-letter country code (US, UK, DE, etc.) |
| `state` | string | State or province name |
| `locality` | string | City name |
| `organization` | string | Organization name |
| `organizational_unit` | string | Department or unit |
| `common_name` | string | CN (must match domain for server) |
| `email` | email | Contact email address |

### Client-Specific Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | string | Yes | Unique client identifier |
| `p12_password` | password | No | Password for P12 file |

## Security Best Practices

1. **Strong Passwords**: Use strong passwords for P12 files
2. **Limit Access**: Only create client certificates for authorized users
3. **Regular Rotation**: Periodically regenerate certificates
4. **Secure Storage**: Backup `/ssl/mtls/` directory securely
5. **Monitor Logs**: Review Caddy logs for unauthorized attempts
6. **Revocation**: Remove client config and regenerate to revoke access

## Troubleshooting

### Common Issues

**Cannot access after enabling mTLS**
- Install client certificate from `/ssl/mtls/`

**Browser doesn't prompt for certificate**
- Ensure certificate is properly installed in browser

**Certificate not accepted**
- Verify CA hasn't been regenerated (would invalidate all certs)
- Check server common_name matches domain exactly

**Certificate errors**
- Ensure server cert common_name matches your domain
- Verify client cert is signed by same CA as server

## Use Cases

- **Zero Trust Access**: Ensure only authorized devices can access Home Assistant
- **Corporate Environments**: Integrate with enterprise PKI
- **Public Exposure**: Safe public internet exposure with cert-based auth
- **IoT Devices**: Authenticate devices with embedded certificates
- **Family Access**: Each family member gets their own certificate
- **Multi-Device**: Different certs for phone, tablet, laptop

## Compatibility

- Works with all Caddy 2 configurations
- Compatible with custom Caddyfiles
- Supports both `non_caddyfile_config` and custom Caddyfile setups
- Platform independent (amd64, aarch64)

## Original Project

Based on: https://github.com/einschmidt/addon-caddy-2

## License

MIT License - Same as original project

## Contributing

Contributions welcome! Please open issues or pull requests.
