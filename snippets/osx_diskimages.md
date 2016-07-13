# OS X Snippets: Disk Images 

The following snippets are used to work with disk images.

_Unless otherwise stated, all examples will be using the El Captian InstallESD.dmg disk image for example output:_

```bash
disk_image="/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg"
```

## Index

* [Format](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#format)
* [Mountpoint](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#mountpoint)

## Snippets

#### Format

Format is any one of the following abbreviations:

| Format | Description           |
|:-------|:----------------------|
| UDRW   | UDIF read/write image |
| UDRO   | UDIF read-only image |
| UDCO   | UDIF ADC-compressed image |
| UDZO   | UDIF zlib-compressed image |
| ULFO   | UDIF lzfse-compressed image (OS X 10.11+ only) |
| UDBZ   | UDIF bzip2-compressed image (Mac OS X 10.4+ only) |
| UDTO   | DVD/CD-R master for export |
| UDSP   | SPARSE (grows with content) |
| UDSB   | SPARSEBUNDLE (grows with content; bundle-backed) |
| UFBI   | UDIF entire image with MD5 checksum |
| UDRo   | UDIF read-only (obsolete format) |
| UDCo   | UDIF compressed (obsolete format) |
| RdWr   | NDIF read/write image (deprecated) |
| Rdxx   | NDIF read-only image (Disk Copy 6.3.3 format; deprecated) |
| ROCo   | NDIF compressed image (deprecated) |
| Rken   | NDIF compressed (obsolete format) |
| DC42   | Disk Copy 4.2 image (obsolete format) |

Returns the current format for disk image at path.

```bash
# Path to the disk image
disk_image=""

# Return the format of the disk image
disk_image_format=$( hdiutil imageinfo "${disk_image}" | awk '/Format:/ { print $NF }' )

# Print output
printf "%s\n" "Disk Image: ${disk_image##*/} has format: ${disk_image_format}"
```

Example using the El Capitan installer InstallESD.dmg disk image:

```
# Output
Disk Image: InstallESD.dmg has format: UDZO
```

#### Mountpoint

Returns the mountpoint for disk image at path.

```bash
# Path to the disk image
disk_image=""

# Return the path (mountpoint) where the disk image is mounted
disk_image_mountpoint=$( hdiutil info -plist | xpath "/plist/dict/key[.='images']/following-sibling::array/dict/key[.='image-path']/following-sibling::string[1][contains(., \"${disk_image}\")]/../key[.='system-entities']/following-sibling::array/dict/key[.='mount-point']/following-sibling::string/text()" 2>/dev/null )

# Check that a path was returned, and that it is a folder
if [[ -n ${disk_image_mountpoint} ]] && [[ -d ${disk_image_mountpoint} ]]; then
    printf "%s\n" "Disk Image: ${disk_image##*/} is mounted at: ${disk_image_mountpoint}"
else
    printf "%s\n" "Disk Image: ${disk_image##*/} is NOT mounted"
fi
```

Example using the El Capitan installer InstallESD.dmg disk image:

```bash
# Output if mounted
Disk Image: InstallESD.dmg is mounted at: /Volumes/OS X Install ESD

# Output if NOT mounted
Disk Image: InstallESD.dmg is NOT mounted
```
