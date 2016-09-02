# OS X Snippets: Disk Images 

The following snippets are used to interact with disk images.

_Unless otherwise stated, all examples will be using the El Captian InstallESD.dmg disk image for example output:_

```bash
disk_image="/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg"
```

## Index

* [Format](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#format)
* [Mountpoint](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#mountpoint)
* [Partition Scheme](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#partition-scheme)
* [Partition Size](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#partition-size)
* [Recovery Partition](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#recovery-partition)
* [Scanned](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_diskimages.md#scanned)

## Snippets

### Format

Returns the current format for disk image at path.

**BASH**
```bash
# Return the format of the disk image
# Using plist output
disk_image_format=$( /usr/libexec/PlistBuddy -c "Print Format" /dev/stdin <<< $( hdiutil imageinfo "${disk_image}" -plist ) )

# Using standard output
# disk_image_format=$( hdiutil imageinfo "${disk_image}" | awk '/Format:/ { print $NF }' )

# Print output
printf "%s\n" "Disk Image: ${disk_image##*/} has format: ${disk_image_format}"
```

Example using the El Capitan installer InstallESD.dmg disk image:

```
# Output
Disk Image: InstallESD.dmg has format: UDZO
```

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

### Mountpoint

Returns the mountpoint for disk image at path.

**BASH**
```bash
# Return the path (mountpoint) where the disk image is mounted
disk_image_mountpoint=$( hdiutil info -plist | xpath "/plist/dict/key[.='images']/following-sibling::array/dict/key[.='image-path']/following-sibling::string[1][contains(., \"${disk_image}\")]/../key[.='system-entities']/following-sibling::array/dict/key[.='mount-point']/following-sibling::string/text()" 2>/dev/null )

# Check that a path was returned, and that it is a folder
if [[ -n ${disk_image_mountpoint} ]] && [[ -d ${disk_image_mountpoint} ]]; then
    printf "%s\n" "Disk Image: ${disk_image##*/} is mounted at: ${disk_image_mountpoint}"
else
    printf "%s\n" "Disk Image: ${disk_image##*/} is NOT mounted"
fi
```

**PYTHON**
```python
import os
import plistlib
import subprocess

# Path to the disk image
disk_image_path = '/Applications/Install OS X El Capitan.app/Contents/SharedSupport/InstallESD.dmg'

def getDiskImageMountpoint(image_path):

	# Run command 'hdiutil info -plist'
	hdiutil_cmd = ['hdiutil', 'info', '-plist']
	hdiutil_subprocess = subprocess.Popen(hdiutil_cmd, stdout=subprocess.PIPE)

	# Read plist returned into variable
	hdiutil_plist = plistlib.readPlist(hdiutil_subprocess.stdout)

	# Loop through all images mounted
	for image in hdiutil_plist['images']:

		# Check if current 'image' is the one we're looking for
		if not image['image-path'] == image_path:
			continue

		# Loop through all entries in the image 'system-entities' array
		for entity in image['system-entities']:

			# Loop through all key-value pairs in entity dictionary
			for key, value in entity.iteritems():

				# If key 'mount-point' is found, return that value as disk image mountpoint
				if key == 'mount-point':
					return value
	return ''

# Return the path (mountpoint) where the disk image is mounted
disk_image_mountpoint = getDiskImageMountpoint(disk_image_path)

# Check that a path was returned, and that it is a folder
if disk_image_mountpoint and os.path.isdir(disk_image_mountpoint):
	print('Disk Image: ' + os.path.basename(disk_image_path) + ' is mounted at: ' + disk_image_mountpoint)
else:
	print('Disk Image: ' + os.path.basename(disk_image_path) + ' is NOT mounted')
```

Example using the El Capitan installer InstallESD.dmg disk image:

Output if mounted:
```console
Disk Image: InstallESD.dmg is mounted at: /Volumes/OS X Install ESD
```

Output if NOT mounted:
```console
Disk Image: InstallESD.dmg is NOT mounted
```

### Partition Scheme

Returns the partition scheme for disk image at path.

**BASH**
```bash
# Return the partition scheme of the disk image
# Using plist output
disk_image_partition_scheme=$( /usr/libexec/PlistBuddy -c "Print partitions:partition-scheme" /dev/stdin <<< $( hdiutil imageinfo "${disk_image}" -plist ) )

# Using standard output
# disk_image_partition_scheme=$( hdiutil imageinfo "${disk_image}" | awk '/partition-scheme:/ { print $NF }' )

# Print output
printf "%s\n" "Disk Image: ${disk_image##*/} has partition scheme: ${disk_image_partition_scheme}"
```

Output:

```console
Disk Image: InstallESD.dmg has partition scheme: GUID
```

### Partition Size

Check the block size of a partition.

**BASH**
```bash
# Return the partition size for the partition name in 'partition_name' of the disk image
# Using plist output
partition_name="Recovery HD"
disk_image_partition_size=$( hdiutil imageinfo -plist | xpath "/plist/dict/key[.='partitions']/following-sibling::*[1]/key[.='partitions']/following-sibling::array/dict/key[.='partition-name']/following-sibling::string[1][contains(., \"Recovery HD\")]/../key[.='partition-length']/following-sibling::integer[1]/text()" 2>/dev/null )

# Print output
printf "%s\n" "Partition named: "${partition_name}" has current block size: "${disk_image_partition_size}"
printf "%s\n" "Partition named: "${partition_name}" has current byte size: $(("${disk_image_partition_size}"*512))
```

Output:

```console
Disk Image: InstallESD.dmg has partition scheme: GUID
```

### Recovery Partition

Check if disk image have a recovery partition.

**BASH**
```bash
if (( $( hdiutil pmap "${disk_image}" | awk '/Apple_Boot/ || /Recovery HD/ { print 1 }' ) )); then
    printf "%s\n" "Disk Image: ${disk_image##*/} have a recovery partition"
else
    printf "%s\n" "Disk Image: ${disk_image##*/} does NOT have a recovery partition"
fi
```

Output using the El Capitan installer InstallESD.dmg disk image:

```console
Disk Image: InstallESD.dmg does NOT have a recovery partition
```

Output using an OS X System disk image created using AutoDMG:

```console
Disk Image: osx_10.11.5_15F34.hfs.dmg have a recovery partition
```
### Scanned

Check if disk image have been scanned for restore.

**BASH**
```bash
# Return 'true' or 'false' depending on if the disk image have been scanned for restore
# Using plist output
disk_image_scanned=$( /usr/libexec/PlistBuddy -c "Print udif-ordered-chunks" /dev/stdin <<< $( hdiutil imageinfo "${disk_image}" -plist ) )

# Using standard output
# disk_image_scanned=$( hdiutil imageinfo "${disk_image}" | awk '/udif-ordered-chunks/ { print $NF }' )

if [[ ${disk_image_scanned} == true ]]; then
    printf "%s\n" "Disk Image: ${disk_image##*/} is scanned for restore"
else
    printf "%s\n" "Disk Image: ${disk_image##*/} is NOT scanned for restore"
fi
```
