# macOS Snippets: NetBoot 

The following snippets are used in a NetBoot environment.

Here is a blogpost I wrote relatex to NetBoot environment variables: [Get BSDP Server IP from a NetBoot client](http://erikberglund.github.io/2016/Get-BSDP-Server-IP-from-a-NetBoot-client/)

## Index

* [BSDP Server IP](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_netboot.md#bsdp-server-ip)
* [DHCP Server IP](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_netboot.md#dhcp-server-ip)
* [Is NetBooted](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_netboot.md#is-netbooted)
* [NBI Name](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_netboot.md#nbi-name)


### BSDP Variables

```bash
ipconfig netbootoption shadow_mount_path
ipconfig netbootoption shadow_file_path
ipconfig netbootoption machine_name
ipconfig netbootoption 17
ipconfig netbootoption 43
ipconfig netbootoption 53
ipconfig netbootoption 54
ipconfig netbootoption 60
ipconfig netbootoption 66
ipconfig netbootoption 67
```

## Snippets

### BSDP Server IP

Get the IP for the server currently netbooted from.

**BASH**  
```bash
ipconfig netbootoption 17 | awk -F'/' '{ print $3 }'
```

Alternate method:

```bash
# Get device id for the boot volume ( example: /dev/disk1s1 )
boot_device_id=$( diskutil info / | awk '/Device Node:/ { print $NF }' )

# Get path for the disk image mounted at "${boot_device_id}"
boot_disk_image_path=$( hdiutil info | awk -v device_id="${boot_device_id}" '{ 
                        if ( $1 == "image-path" ) { 
                            disk_image_path=$NF;
                        } else if ( $1 == device_id ) { 
                            print disk_image_path; exit 0 
                        } }' )

# Print the IP for the BSDP Server
awk -F'/' '{ print $3 }' <<< "${boot_disk_image_path}"
```

Output:

```console
10.2.0.10
```

### DHCP Server IP

Get the IP for the DHCP server.

**BASH**  
```bash
ipconfig netbootoption 54
```

Output:

```console
10.2.0.1
```

### Is NetBooted

Check if the computer is currently netbooted

**BASH**  
```bash
if [[ $( sysctl -n kern.netboot ) ]]; then
	echo "Not NetBooted";
else
	echo "NetBooted";
fi
```

Output:

```console
NetBooted
```

### NBI Name

Get the name of the NBI currently booted from.

**BASH**  
```bash
ipconfig netbootoption 17 | sed -nE 's/.*\/(.*\.nbi)\/.*/\1/p'
```

Output:

```console
10.12-16A323_Imagr.nbi
```