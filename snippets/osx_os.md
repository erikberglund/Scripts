# OS X Snippets: OS 

The following snippets are used to extract os information from an OS X system.

## Index

* [OS Version](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-version)
* [OS Build Version](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-build-version)
* [OS Marketing Name](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-marketing-name)

## Snippets

#### OS Version

On a running system:

```bash
sw_vers -productVersion
```

On a mounted system:

```bash
/usr/libexec/PlistBuddy -c "Print ProductVersion" "/System/Library/CoreServices/SystemVersion.plist"
```

A variable for each component of the version string:

```bash
IFS='.' read -r major minor patch < <( /usr/bin/sw_vers -productVersion )

# Now the variables hold the following values:
(major=10)
(minor=11)
(patch=4)
```

#### OS Build Version

On a running system:

```bash
sw_vers -buildVersion
```

On a mounted system:

```bash
/usr/libexec/PlistBuddy -c "Print ProductBuildVersion" "/System/Library/CoreServices/SystemVersion.plist"
```

#### OS Marketing Name

**NOTE! Requires an internet connection**

```bash
curl -s http://support-sp.apple.com/sp/product?edid=$( sw_vers -productVersion ) | xpath '/root/configCode/text()' 2>/dev/null
```