## letsEncryptJSS

This script sets up and manages Let's Encrypt for a JSS running on Ubuntu 14.04.

### Configuration

Configure the following variables before using the script:

**sslEmail**

```bash
# E-mail address for the certificate CA
sslEmail="ca@example.com"
```

**sslDomain**

```bash
# Domain for the certificate
sslDomain="jss.example.com"
```

**tomcatKeystorePassword**

```bash
# Password for Tomcat keystore
tomcatKeystorePassword="passw0rd"
```