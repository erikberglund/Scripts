# OS X Snippets: Hardware 

#### Serial Number (Computer)

```bash
serialnumber=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}' )
```

#### Serial Number (Logic Board)

```bash
mlb_serialnumber=$( nvram 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:MLB | awk '{ print $NF }' )
```

#### MAC Address

The MAC Address for an interface, in the example, `en0`

```bash
mac_address=$( ifconfig en0 | awk '/ether/{ gsub(":",""); print toupper($2)}' )
```

#### MAC Address (Logic Board)

```bash
mlb_mac_address=$( nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM | awk '{ gsub(/\%/, ""); print $NF }' )
```

#### Board ID

```bash
boardid=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/board-id/{print $(NF-1)}' )
```

#### Model Identifier/ModelID/Machine Model

```bash
modelid=$( sysctl -n hw.model )
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
ram=$(( $( sysctl -n hw.memsize ) >> 30 ))
```

RAM installed (in MB without unit)

```bash
ram=$(( $( sysctl -n hw.memsize ) >> 20 ))
```

#### Marketing Name

**NOTE! Requires an internet connection**

```bash
marketing_name=$( curl -s http://support-sp.apple.com/sp/product?cc=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ sn=$(NF-1); if (length(sn) == 12) count=3; else if (length(sn) == 11) count=2; print substr(sn, length(sn) - count, length(sn))}' ) | xpath '/root/configCode/text()' 2>/dev/null )
```