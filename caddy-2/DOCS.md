# Home Assistant Add-on: Caddy 2

Caddy 2 is a modern, powerful, enterprise-grade open-source web server designed for simplicity, security, and flexibility.
It's unique in its ability to automatically manage HTTPS by default, without any complex configuration.

## Table of Contents

1. [Add-on Installation](#add-on-installation)
2. [Basic Setup Examples](#basic-setup-examples)
3. [Configuration Options](#configuration-options)
4. [mTLS Configuration](#mtls-configuration)
5. [Advanced Usage: Custom Binaries & Plugins](#advanced-usage-custom-binaries--plugins)

## Add-on Installation

To install the Caddy 2 add-on, first add the repository to your [Hass.io](https://home-assistant.io/hassio/) instance by entering the following URL:

`https://github.com/einschmidt/hassio-addons`

If you encounter any issues, refer to the [official documentation](https://home-assistant.io/hassio/installing_third_party_addons/) for guidance.

Once the repository is added, search for and install the "Caddy 2" add-on.

## Basic Setup Examples

The Caddy 2 add-on offers multiple setup methods to accommodate different environments and network configurations. These setups range from simple to more complex, allowing you to choose the level of customization that fits your needs.

### Default Proxy Server Setup (Simple)

By default, Caddy 2 runs as a proxy server for Home Assistant without needing a `Caddyfile`. It uses the configuration provided in the add-on settings and automatically handles HTTPS for you.

**Note**: If a `Caddyfile` is found in the configuration directory, the `non_caddyfile_config` settings will be ignored in favor of the Caddyfile.

#### Example Configuration

**Important**: _Always restart the add-on after making changes to the configuration._

For a basic proxy setup, forwarding `yourdomain.com` to Home Assistant, use the following example (without a `Caddyfile`):

```yaml
non_caddyfile_config:
  email: your@email.com
  domain: yourdomain.com
  destination: localhost
  port: 8123
log_level: info
args: []
env_vars: []
```

**Note**: _These examples are for guidance only. Customize them according to your needs._

### Caddyfile Setup (Intermediate)

For more advanced customization, you can create and use a Caddyfile to define your proxy server's configuration. This allows greater control over settings such as routing, headers, and SSL management.

To use a Caddyfile, place the file in the add-on configuration directory. You can access this directory using either the [SSH][ssh] or [Samba][samba] add-ons. The add-on will only search for the Caddyfile in this specific location.

#### Add-on Configuration Directory

The Caddyfile needs to be placed in the add-on's configuration directory, which can be found at:

```
/addon_configs/c80c7555_caddy-2
```

##### Accessing the Configuration Directory

SSH: You can access the configuration directory via SSH by navigating to `/addon_configs/`.

Samba: Alternatively, with the Samba add-on, you can access this folder from your network as a shared directory. Look for the `addon_configs` folder and locate the appropriate directory.

#### Managing Certificates

Caddy 2 can automatically generate SSL certificates. If you want to use certificates from other add-ons (such as the Let's Encrypt add-on), they can be placed in the `/ssl` directory. The Caddy 2 add-on will have access to this folder, allowing you to use external certificates or create certificates for other services.

#### Example Caddyfile

A simple Caddyfile for proxying traffic to a Home Assistant installation might look like this:

```
{
  email your@email.com
}

yourdomain.com {
  reverse_proxy localhost:8123
}
```

For more advanced configurations, refer to the [Caddyfile documentation](https://caddyserver.com/docs/caddyfile).

#### Example Configuration for Caddyfile

**Important**: _Restart the add-on after changing the configuration._

To instruct the add-on to use and monitor the `Caddyfile`, your configuration should look like this:

```yaml
non_caddyfile_config: {}
log_level: info
args:
  - "--watch"
env_vars: []
```

**Note**: _Customize this example for your specific setup._

### Custom Caddy Binary Setup (Advanced)

For advanced users, you can replace the default Caddy binary with a custom one. Place your `caddy` binary in the [add-on configuration directory](#add-on-configuration-directory), using [SSH][ssh] or [Samba][samba]. The add-on will use binaries found in this folder.

#### Example Configuration

**Important**: _Restart the add-on after any configuration changes._

Here's an example configuration using a custom Caddy binary and a `Caddyfile`, with automatic updates and formatting enabled:

```yaml
non_caddyfile_config: {}
log_level: info
args:
  - "--watch"
env_vars: []
caddy_upgrade: true
caddy_fmt: true
```

**Note**: _These examples are meant for reference. Adjust them to match your setup._

## Configuration Options

### Option: `non_caddyfile_config.email`

Defines the email address used when creating an ACME account with your Certificate Authority (CA). This is recommended to help manage certificates in case of issues.

**Note**: This option is only used for the default reverse proxy setup. It will be ignored once a `Caddyfile` is found in the configuration directory.

### Option: `non_caddyfile_config.domain`

Specifies the domain name for your setup.

**Note**: This option is only applicable to the default reverse proxy setup and will be ignored if a `Caddyfile` is present in the configuration directory.

### Option: `non_caddyfile_config.destination`

Sets the upstream address for the reverse proxy. Typically, `localhost` is sufficient for most setups. To target specific addresses, you can use `127.0.0.1` for IPv4 or `::1` for IPv6.

**Note**: This option is only used for the default reverse proxy setup and is ignored if a `Caddyfile` is found in the configuration directory.

### Option: `non_caddyfile_config.port`

Defines the port for the upstream address. For example, Home Assistant typically uses port `8123`.

**Note**: This setting is only applied in the default reverse proxy configuration. It is ignored if a `Caddyfile` is present in the configuration directory.

### Option: `caddy_upgrade`

Enables automatic upgrades for custom Caddy binaries and their plugins. Set this option to `true` to allow updates, or `false` to disable it. The default is `false`.

**Note**: This feature only applies to custom binaries (Caddy version 2.4 or higher) and is not needed if using the default Caddy binary.

### Option: `caddy_fmt`

Enables automatic formatting and prettifying of the `Caddyfile`. Set this option to `true` to enable formatting or `false` to disable it. By default, it is disabled.

**Note**: This feature requires a valid `Caddyfile` to work.

### Option: `args`

Allows you to specify additional command-line arguments for Caddy 2. Add one or more arguments to the list, and they will be executed each time the add-on starts.

**Note**: The `--config` argument is automatically added. For more information, refer to the official [Caddy documentation](https://caddyserver.com/docs/command-line#caddy-run).

### Option: `env_vars`

Allows you to define multiple environment variables, usually used for custom Caddy binary builds. These variables can be set in the following format:

Example:

```yaml
env_vars:
  - name: NAMECHEAP_API_USER
    value: xxxx
  - name: NAMECHEAP_API_KEY
    value: xxxx
```

### Option: `env_vars.name`

Specifies the name of the environment variable.

### Option: `env_vars.value`

Specifies the value assigned to the environment variable.

### Option: `log_level`

Controls the verbosity of the log output from the add-on. This setting is useful for debugging or monitoring the add-on's behavior. Available log levels are:

- `trace`: Shows detailed information, including all internal function calls.
- `debug`: Provides extensive debugging information.
- `info`: Shows typical events and information.
- `warning`: Logs unexpected situations that are not errors.
- `error`: Records runtime errors that don't need immediate action.
- `fatal`: Critical errors that make the add-on unusable.

Each level includes the messages from more severe levels. For example, `debug` also includes `info` messages. The default setting is `info`, which is recommended unless troubleshooting.

## mTLS Configuration

This add-on supports mutual TLS (mTLS) authentication, which provides an additional layer of security by requiring both the server and client to authenticate each other using certificates. This is particularly useful for securing access to your Home Assistant instance.

### What is mTLS?

Mutual TLS (mTLS) is an authentication method where both the client and server verify each other's identity using X.509 certificates. Unlike standard TLS where only the server is authenticated, mTLS requires clients to present valid certificates signed by a trusted Certificate Authority (CA).

### Automated Certificate Management

The add-on automatically handles all certificate generation and management. When enabled, it will:

1. Generate a Certificate Authority (CA) certificate
2. Generate a server certificate signed by the CA
3. Generate client certificates for authorized users
4. Export client certificates in PKCS#12 (.p12) format for easy import into browsers and applications

All certificates are stored in `/ssl/mtls/` and persist across add-on restarts.

### Basic mTLS Setup Example

Here's a minimal configuration to enable mTLS:

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

### Complete mTLS Configuration Example

Here's a more comprehensive example with all available options:

```yaml
non_caddyfile_config:
  email: your@email.com
  domain: yourdomain.com
  destination: localhost
  port: 8123
mtls:
  enabled: true
  regenerate_ca: false
  regenerate_server: false
  regenerate_clients: false
  ca:
    country: US
    state: California
    locality: San Francisco
    organization: My Smart Home
    organizational_unit: IT Security
    common_name: Home Assistant CA
    email: ca@yourdomain.com
  server:
    country: US
    state: California
    locality: San Francisco
    organization: My Smart Home
    organizational_unit: IT
    common_name: yourdomain.com
    email: server@yourdomain.com
  clients:
    - name: john_doe
      country: US
      state: California
      locality: San Francisco
      organization: My Smart Home
      organizational_unit: Users
      common_name: John Doe
      email: john@yourdomain.com
      p12_password: johns_secure_password
    - name: jane_doe
      country: US
      state: California
      locality: San Francisco
      organization: My Smart Home
      organizational_unit: Users
      common_name: Jane Doe
      email: jane@yourdomain.com
      p12_password: janes_secure_password
log_level: info
```

### mTLS Configuration Options

#### Option: `mtls.enabled`

Enables or disables mTLS authentication. Set to `true` to enable mTLS, or `false` to disable it. Default is `false`.

#### Option: `mtls.regenerate_ca`

Forces regeneration of the CA certificate on next restart. Set to `true` to regenerate, `false` to keep existing. Default is `false`.

**Warning**: Regenerating the CA will invalidate all existing server and client certificates.

#### Option: `mtls.regenerate_server`

Forces regeneration of the server certificate on next restart. Set to `true` to regenerate, `false` to keep existing. Default is `false`.

#### Option: `mtls.regenerate_clients`

Forces regeneration of all client certificates on next restart. Set to `true` to regenerate, `false` to keep existing. Default is `false`.

#### Option: `mtls.ca.*`

Configuration for the Certificate Authority certificate:

- **country**: Two-letter country code (e.g., `US`, `UK`, `DE`)
- **state**: State or province name
- **locality**: City name
- **organization**: Organization name
- **organizational_unit**: Department or unit name
- **common_name**: CA name (this will appear in certificate details)
- **email**: Contact email for the CA

#### Option: `mtls.server.*`

Configuration for the server certificate:

- **country**: Two-letter country code
- **state**: State or province name
- **locality**: City name
- **organization**: Organization name
- **organizational_unit**: Department or unit name
- **common_name**: Server FQDN (must match your domain name)
- **email**: Contact email for the server

**Important**: The `common_name` must match the domain you're using to access your Home Assistant instance.

#### Option: `mtls.clients`

List of client certificates to generate. Each client entry contains:

- **name**: Unique identifier for the client (used in filenames)
- **country**: Two-letter country code
- **state**: State or province name
- **locality**: City name
- **organization**: Organization name
- **organizational_unit**: Department or unit name
- **common_name**: User's full name or identifier
- **email**: User's email address
- **p12_password**: Password for the PKCS#12 file (optional but recommended)

### Accessing Client Certificates

Client certificates are generated in PKCS#12 (.p12) format and stored in `/ssl/mtls/`. You can access them using:

1. **SSH Add-on**: Navigate to `/ssl/mtls/` and download the `.p12` files
2. **Samba Add-on**: Access the `ssl` share and navigate to the `mtls` folder
3. **File Editor Add-on**: Browse to `/ssl/mtls/`

The files will be named: `mTLS-client-{name}.p12` where `{name}` is the client name you specified in the configuration.

### Installing Client Certificates

#### On Desktop Browsers

**Chrome/Edge:**
1. Go to Settings → Privacy and security → Security → Manage certificates
2. Import the `.p12` file
3. Enter the password you configured
4. Restart the browser

**Firefox:**
1. Go to Settings → Privacy & Security → Certificates → View Certificates
2. Click "Import"
3. Select the `.p12` file
4. Enter the password you configured
5. Restart the browser

**Safari (macOS):**
1. Double-click the `.p12` file
2. It will open Keychain Access
3. Enter the password and select a keychain
4. Restart Safari

#### On Mobile Devices

**iOS:**
1. Email the `.p12` file to yourself or use AirDrop
2. Tap the file to install
3. Go to Settings → General → VPN & Device Management → Install Profile
4. Enter the password and your device passcode

**Android:**
1. Transfer the `.p12` file to your device
2. Go to Settings → Security → Install from storage
3. Select the `.p12` file
4. Enter the password
5. Name the certificate

### Using mTLS with Custom Caddyfile

If you're using a custom Caddyfile, you can configure mTLS manually:

```
{
    email your@email.com
}

yourdomain.com {
    tls /ssl/mtls/mTLS-server.crt /ssl/mtls/mTLS-server.key {
        client_auth {
            mode require_and_verify
            trusted_ca_cert_file /ssl/mtls/mTLS-CA.crt
        }
    }
    reverse_proxy localhost:8123
}
```

### Security Best Practices

1. **Use Strong Passwords**: Always set a strong `p12_password` for client certificates
2. **Limit Client Certificates**: Only create certificates for users who need access
3. **Regular Rotation**: Periodically regenerate certificates by setting the regenerate flags to `true`
4. **Secure Storage**: Keep the `/ssl/mtls/` directory secure and backed up
5. **Monitor Access**: Check Caddy logs regularly for unauthorized access attempts
6. **Revocation**: To revoke a client's access, remove their entry from the config and set `regenerate_clients: true`

### Troubleshooting mTLS

**Issue**: Browser shows "Certificate Error" or "Connection Refused"
- **Solution**: Ensure the server's `common_name` matches your domain exactly

**Issue**: Browser doesn't prompt for client certificate
- **Solution**: Verify the client certificate is properly installed in your browser

**Issue**: "Certificate not trusted" error
- **Solution**: The CA certificate needs to be trusted. Install `mTLS-CA.crt` in your system's trusted certificate store

**Issue**: Cannot access the Home Assistant after enabling mTLS
- **Solution**: You need to install a client certificate. Access the `/ssl/mtls/` directory via SSH/Samba to retrieve your `.p12` file

**Issue**: Client certificate is not being accepted
- **Solution**: Check that the certificate hasn't expired and was signed by the same CA. If you regenerated the CA, you need to regenerate all client certificates too.

## Advanced Usage: Custom Binaries & Plugins

### Overview

This add-on uses a single binary file to launch Caddy, which makes it highly customizable. You can run a custom build of Caddy with any version and plugins you need, providing maximum flexibility for advanced users.

### Custom Caddy Binaries

To build your own version of Caddy, including specific plugins or features, you can follow the instructions provided in the official Caddy documentation using the [`xcaddy` tool](https://caddyserver.com/docs/build#xcaddy). This allows you to compile your own version of Caddy with custom modules or plugins that are not included in the default binary.

### Installing a Custom Binary

To use a custom-built Caddy binary, follow these steps:

1. Build your custom Caddy binary using `xcaddy` or obtain a pre-built version that suits your needs.
2. Place the `caddy` binary file into the add-on configuration folder.
3. Restart the Caddy 2 add-on to begin using your custom version of Caddy.

#### Accessing the Configuration Folder

The add-on configuration folder can be found at:

```
/addon_configs/c80c7555_caddy-2
```

This is where you should place your custom `caddy` binary and any related configuration files.

Once the add-on is restarted, Caddy will use the custom binary you've provided, allowing you to leverage any additional features or plugins included in your custom build.

[ssh]: https://home-assistant.io/addons/ssh/
[samba]: https://home-assistant.io/addons/samba/
