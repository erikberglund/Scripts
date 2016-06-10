# OS X Snippets: OS 

The following snippets are used to extract os information from an OS X system.

## Index

* [OS Version](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-version)
* [OS Build Version](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-build-version)
* [OS Marketing Name](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_os.md#os-marketing-name)

## Snippets

#### OS Version

On a running system you can use the `sw_vers` command to query the os version.

```bash
sw_vers -productVersion
10.11.5
```

You can also query the `SystemVersion.plist` file directly (useful for checking mounted systems):

```bash
/usr/libexec/PlistBuddy -c "Print ProductVersion" "/System/Library/CoreServices/SystemVersion.plist"
10.11.5
```

If you need each component of the version string in separate variables, use the `read` command:

```bash
IFS='.' read -r major minor patch < <( /usr/bin/sw_vers -productVersion )

# Now the variables hold the following values:
# major=10
# minor=11
# patch=5
```

#### OS Build Version

On a running system you can use the `sw_vers` command to query the os build version.

```bash
sw_vers -buildVersion
15F34
```

You can also query the `SystemVersion.plist` file directly (useful for checking mounted systems):

```bash
/usr/libexec/PlistBuddy -c "Print ProductBuildVersion" "/System/Library/CoreServices/SystemVersion.plist"
15F34
```

#### OS Marketing Name

**NOTE! Requires an internet connection**

This retrieves the marketing name for an OS X version string from Apple's server.

```bash
curl -s http://support-sp.apple.com/sp/product?edid=$( sw_vers -productVersion ) | xpath '/root/configCode/text()' 2>/dev/null
OS X El Capitan
```