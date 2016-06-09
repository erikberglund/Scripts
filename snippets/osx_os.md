# OS X Snippets: OS 

### OS Version

Full version string:

```bash
os_version=$( sw_vers -productVersion )
```

A variable for each component of the version string:

```bash
IFS='.' read -r major minor patch < <( /usr/bin/sw_vers -productVersion )

# Now the variables hold the following values:
(major=10)
(minor=11)
(patch=4)
```

### OS Build Version

```bash
os_build=$( sw_vers -buildVersion )
```

### OS Marketing Name

**NOTE! Requires an internet connection**

```bash
curl -s http://support-sp.apple.com/sp/product?edid=$( sw_vers -productVersion ) | xpath '/root/configCode/text()' 2>/dev/null
```