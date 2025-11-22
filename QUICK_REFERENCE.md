# mTLS Quick Reference Guide

## 🚀 Quick Start

### Minimal Configuration
```yaml
mtls:
  enabled: true
  ca:
    common_name: My Home CA
    email: ca@example.com
  server:
    common_name: mydomain.com  # Must match your domain!
    email: server@example.com
  clients:
    - name: my_phone
      common_name: My Phone
      email: me@example.com
      p12_password: MySecurePassword123
```

## 📁 Certificate Locations

All certificates are stored in `/ssl/mtls/`:

| File | Description |
|------|-------------|
| `mTLS-CA.crt` | CA certificate (can be shared) |
| `mTLS-CA.key` | CA private key (keep secure!) |
| `mTLS-server.crt` | Server certificate |
| `mTLS-server.key` | Server private key |
| `mTLS-client-{name}.p12` | Client certificate bundle (distribute to users) |

## 💻 Client Certificate Installation

### Chrome/Edge (Desktop)
1. Settings → Privacy and security → Security → Manage certificates
2. Import → Select `.p12` file
3. Enter password → OK
4. Restart browser

### Firefox (Desktop)
1. Settings → Privacy & Security → Certificates → View Certificates
2. Your Certificates → Import
3. Select `.p12` file → Enter password
4. Restart browser

### Safari (macOS)
1. Double-click `.p12` file
2. Enter password in Keychain Access
3. Restart Safari

### iOS
1. Email `.p12` to yourself or AirDrop
2. Tap file → Install
3. Settings → General → VPN & Device Management
4. Install profile → Enter password

### Android
1. Transfer `.p12` to device
2. Settings → Security → Install from storage
3. Select file → Enter password → Name it

## 🔧 Common Configurations

### Single User
```yaml
mtls:
  enabled: true
  ca:
    common_name: My Home CA
  server:
    common_name: home.example.com
  clients:
    - name: admin
      common_name: Admin User
      email: admin@example.com
      p12_password: SecurePass123
```

### Multiple Users
```yaml
mtls:
  enabled: true
  ca:
    common_name: Family Home CA
  server:
    common_name: home.example.com
  clients:
    - name: dad
      common_name: Dad
      email: dad@family.com
      p12_password: DadsPassword
    - name: mom
      common_name: Mom
      email: mom@family.com
      p12_password: MomsPassword
    - name: kids_tablet
      common_name: Kids Tablet
      email: kids@family.com
      p12_password: KidsPassword
```

### Enterprise Setup
```yaml
mtls:
  enabled: true
  ca:
    country: US
    state: California
    locality: San Francisco
    organization: Acme Corp
    organizational_unit: IT Security
    common_name: Acme Home Assistant CA
    email: it@acme.com
  server:
    country: US
    state: California
    locality: San Francisco
    organization: Acme Corp
    organizational_unit: Infrastructure
    common_name: ha.acme.com
    email: infrastructure@acme.com
  clients:
    - name: employee_001
      country: US
      state: California
      locality: San Francisco
      organization: Acme Corp
      organizational_unit: Engineering
      common_name: John Doe
      email: john.doe@acme.com
      p12_password: Str0ng!Pass
```

## 🔄 Certificate Management

### Adding a New User
1. Add client to config:
```yaml
clients:
  - name: new_user
    common_name: New User Name
    email: newuser@example.com
    p12_password: TheirPassword
```
2. Restart addon
3. Retrieve `/ssl/mtls/mTLS-client-new_user.p12`
4. Send to user securely

### Removing a User
1. Remove client from config
2. Set `regenerate_clients: true`
3. Restart addon
4. Redistribute `.p12` files to remaining users

### Rotating All Certificates
```yaml
mtls:
  regenerate_ca: true      # Regenerates everything
  regenerate_server: true
  regenerate_clients: true
```
After restart, set all back to `false` and distribute new client certs.

### Rotating Only Client Certificates
```yaml
mtls:
  regenerate_clients: true  # Only regenerates client certs
```

## 🐛 Troubleshooting

### Problem: Cannot access Home Assistant after enabling mTLS
**Solution:** You need to install a client certificate
1. Access `/ssl/mtls/` via SSH or Samba
2. Download your `.p12` file
3. Install in your browser (see installation steps above)

### Problem: Browser doesn't ask for certificate
**Solution:** Certificate not installed properly
1. Check browser's certificate manager
2. Verify `.p12` file imported successfully
3. Restart browser

### Problem: "Certificate not trusted" error
**Solution:** Server certificate issue
1. Verify `server.common_name` matches your domain exactly
2. Check `/ssl/mtls/mTLS-server.crt` exists
3. Check Caddy logs for errors

### Problem: Client certificate rejected
**Solution:** Certificate mismatch
1. Verify client cert signed by same CA
2. Check if CA was regenerated (invalidates old certs)
3. If CA regenerated, set `regenerate_clients: true`

### Problem: "Connection refused" after config change
**Solution:** Check Caddy logs
```bash
docker logs addon_xxx_caddy-2
```

## 📊 Verification Steps

### 1. Check certificates exist
```bash
ls -la /ssl/mtls/
```
Should show: CA cert/key, server cert/key, client .p12 files

### 2. Verify certificate details
```bash
openssl x509 -in /ssl/mtls/mTLS-server.crt -text -noout
```
Check:
- Subject CN matches domain
- Issuer matches CA
- Validity dates

### 3. Test client certificate
```bash
openssl pkcs12 -info -in /ssl/mtls/mTLS-client-{name}.p12
```
Enter password when prompted

### 4. Check Caddy configuration
Look for these in logs:
- "Running mTLS setup..."
- "CA certificate generated successfully"
- "Server certificate generated successfully"
- "Client certificate for {name} generated successfully"

## 🔐 Security Checklist

- [ ] Strong P12 passwords set
- [ ] Only necessary users have certificates
- [ ] `/ssl/mtls/` backed up securely
- [ ] CA private key protected (never share)
- [ ] Server common_name matches domain
- [ ] Certificates distributed via secure channel
- [ ] Old certificates removed after rotation
- [ ] Monitoring enabled for failed auth attempts

## 📞 Getting Help

1. Check addon logs: `docker logs addon_xxx_caddy-2`
2. Verify config syntax in Home Assistant UI
3. Review DOCS.md for detailed documentation
4. Check IMPLEMENTATION.md for technical details
5. Create GitHub issue with logs and config (redact passwords!)

## 🎯 Use Cases

### Home Access Only
- Generate one cert per family member
- Install on all their devices
- No password needed after cert install

### Multi-Location
- Different certs for home/work/mobile
- Easy to revoke if device lost
- Granular access control

### IoT Integration
- Embed cert in automation tools
- Secure API access
- No password authentication

### Remote Admin
- Admin gets separate cert
- Higher security for privileged access
- Easy to audit access logs

## 🔗 Related Commands

### View CA details
```bash
openssl x509 -in /ssl/mtls/mTLS-CA.crt -text -noout
```

### View server cert details
```bash
openssl x509 -in /ssl/mtls/mTLS-server.crt -text -noout
```

### Extract cert from P12
```bash
openssl pkcs12 -in /ssl/mtls/mTLS-client-{name}.p12 -clcerts -nokeys -out cert.pem
```

### Test mTLS connection
```bash
curl --cert cert.pem --key key.pem --cacert /ssl/mtls/mTLS-CA.crt https://yourdomain.com
```

## 📝 Configuration Template

Copy and customize:

```yaml
non_caddyfile_config:
  email: YOUR_EMAIL
  domain: YOUR_DOMAIN
  destination: localhost
  port: 8123

mtls:
  enabled: true
  regenerate_ca: false
  regenerate_server: false
  regenerate_clients: false

  ca:
    country: XX
    state: Your State
    locality: Your City
    organization: Your Org
    organizational_unit: Your Unit
    common_name: Your CA Name
    email: ca@yourdomain.com

  server:
    country: XX
    state: Your State
    locality: Your City
    organization: Your Org
    organizational_unit: Your Unit
    common_name: YOUR_DOMAIN  # MUST MATCH DOMAIN ABOVE
    email: server@yourdomain.com

  clients:
    - name: client1
      country: XX
      state: Your State
      locality: Your City
      organization: Your Org
      organizational_unit: Users
      common_name: Client 1 Name
      email: client1@yourdomain.com
      p12_password: SECURE_PASSWORD_HERE

log_level: info
args: []
env_vars: []
```
