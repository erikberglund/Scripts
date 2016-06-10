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
```

You can also query the `SystemVersion.plist` file directly (useful for checking mounted systems):

```bash
/usr/libexec/PlistBuddy -c "Print ProductVersion" "/System/Library/CoreServices/SystemVersion.plist"
```

If you need each component of the version string in separate variables, use the `read` command:

```bash
IFS='.' read -r major minor patch < <( /usr/bin/sw_vers -productVersion )

# Now the variables hold the following values:
(major=10)
(minor=11)
(patch=4)
```

#### OS Build Version

On a running system you can use the `sw_vers` command to query the os build version.

```bash
sw_vers -buildVersion
```

You can also query the `SystemVersion.plist` file directly (useful for checking mounted systems):

```bash
/usr/libexec/PlistBuddy -c "Print ProductBuildVersion" "/System/Library/CoreServices/SystemVersion.plist"
```

#### OS Marketing Name

**NOTE! Requires an internet connection**

This retrieves the marketing name for a OS X version string from Apple's server.

```bash
curl -s http://support-sp.apple.com/sp/product?edid=$( sw_vers -productVersion ) | xpath '/root/configCode/text()' 2>/dev/null
```