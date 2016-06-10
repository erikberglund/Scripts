# OS X Snippets: Hardware 

* [Serial Number (Computer)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#serial-number-computer)
* [Serial Number (Logic Board)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#serial-number-logic-board)
* [MAC Address](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#mac-address)
* [MAC Address (Logic Board)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#mac-address-logic-board)
* [Board ID](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#board-id)
* [Model Identifier / Machine Model](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#model-identifier--machine-model)
* [RAM Installed](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#ram-installed)
* [Marketing Name](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#marketing-name)

#### Serial Number (Computer)

```bash
ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ print $(NF-1) }'
```

#### Serial Number (Logic Board)

```bash
nvram 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:MLB | awk '{ print $NF }'
```

#### MAC Address

The MAC Address for an interface, in the example, `en0`

```bash
ifconfig en0 | awk '/ether/{ gsub(":",""); print $2 }'
```

Uppercase output:

```bash
ifconfig en0 | awk '/ether/{ gsub(":",""); print toupper($2) }'
```

#### MAC Address (Logic Board)

```bash
nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM | awk '{ gsub(/\%/, ""); print $NF }'
```

Uppercase output:

```bash
nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM | awk '{ gsub(/\%/, ""); print toupper($NF) }'
```


#### Board ID

```bash
ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/board-id/{ print $(NF-1) }'
```

#### Model Identifier / Machine Model

```bash
sysctl -n hw.model
```

#### Laptop/Desktop

```bash
if [[ $( sysctl -n hw.model ) =~ [Bb]ook ]]; then
	printf "%s" "Laptop"
else
	printf "%s" "Desktop"	
fi
```

#### RAM Installed

RAM installed (in GB without unit)

```bash
$(( $( sysctl -n hw.memsize ) >> 30 ))
```

RAM installed (in MB without unit)

```bash
$(( $( sysctl -n hw.memsize ) >> 20 ))
```

#### Marketing Name

**NOTE! Requires an internet connection**

```bash
curl -s http://support-sp.apple.com/sp/product?cc=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ sn=$(NF-1); if (length(sn) == 12) count=3; else if (length(sn) == 11) count=2; print substr(sn, length(sn) - count, length(sn)) }' ) | xpath '/root/configCode/text()' 2>/dev/null
```