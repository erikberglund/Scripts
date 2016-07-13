# OS X Snippets: Disk Images 

The following snippets are used to work with disk images.

## Index

* [Mountpoint](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#mountpoint)

## Snippets

#### Mountpoint

Returns the mountpoint for disk image at path.

```bash
# Path to the disk image
disk_image=""

# Return the mountpoint where the disk image is mounted
disk_image_mountpoint=$( hdiutil info -plist | xpath "/plist/dict/key[.='images']/following-sibling::array/dict/key[.='image-path']/following-sibling::string[1][contains(., \"${disk_image}\")]/../key[.='system-entities']/following-sibling::array/dict/key[.='mount-point']/following-sibling::string/text()" 2>/dev/null )

# Check that mountpoint path returned is a folder
if [[ -n ${disk_image_mountpoint} ]] && [[ -d ${disk_image_mountpoint} ]]; then
    printf "%s\n" "${disk_image##*/} is mounted at: ${disk_image_mountpoint}"
else
    printf "%s\n" "No mountpoint returned for disk image: ${disk_image##*/}"
fi
```

Example using the El Capitan installer:

```bash
disk_image="/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg"

# Output if mounted
InstallESD.dmg is mounted at: /Volumes/OS X Install ESD

# Output if NOT mounted
No mountpoint returned for disk image: InstallESD.dmg
```
