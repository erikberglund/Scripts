# OS X Snippets: Hardware 

The following snippets are used to extract hardware information from a running OS X system.

## Index

* [Serial Number (Computer)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#serial-number-computer)
* [Serial Number (Logic Board)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#serial-number-logic-board)
* [MAC Address](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#mac-address)
* [MAC Address (Logic Board)](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#mac-address-logic-board)
* [Battery Percent](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#battery-percent)
* [Board ID](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#board-id)
* [Model Identifier / Machine Model](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#model-identifier--machine-model)
* [RAM Installed](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#ram-installed)
* [Marketing Name](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#marketing-name)
* [Virtual Machine](https://github.com/erikberglund/Scripts/blob/master/snippets/osx_hardware.md#virtual-machine)

## Snippets

#### Serial Number (Computer)

```bash
ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ print $(NF-1) }'
C02*****G8WP
```

#### Serial Number (Logic Board)

```bash
nvram 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:MLB | awk '{ print $NF }'
C0252******GF2C1H
```

#### MAC Address

The MAC Address for an interface, in the example, `en0`

```bash
ifconfig en0 | awk '/ether/{ gsub(":",""); print $2 }'
a45e60******
```

Uppercase output:

```bash
ifconfig en0 | awk '/ether/{ gsub(":",""); print toupper($2) }'
A45E60******
```

#### MAC Address (Logic Board)

```bash
nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM | awk '{ gsub(/\%/, ""); print $NF }'
0cbc9f******
```

Uppercase output:

```bash
nvram -x 4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14:ROM | awk '{ gsub(/\%/, ""); print toupper($NF) }'
0CBC9F******
```

#### Battery Percent

Displays current battery charge percentage:

```bash
ioreg -rd1 -c AppleSmartBattery | awk '/MaxCapacity/ {max=$NF}; /CurrentCapacity/ {current=$NF} END{OFMT="%.2f%%"; print((100*current)/max)}'
52,96%
```

#### Board ID

```bash
ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/board-id/{ print $(NF-1) }'
Mac-06F11F11946D27C5
```

#### Model Identifier / Machine Model

```bash
sysctl -n hw.model
MacBookPro11,5
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
printf "%s\n" "${ram}"
16
```

RAM installed (in MB without unit)

```bash
ram=$(( $( sysctl -n hw.memsize ) >> 20 ))
printf "%s\n" "${ram}"
16384
```

#### Marketing Name

**NOTE! Requires an internet connection**

```bash
curl -s http://support-sp.apple.com/sp/product?cc=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ sn=$(NF-1); if (length(sn) == 12) count=3; else if (length(sn) == 11) count=2; print substr(sn, length(sn) - count, length(sn)) }' ) | xpath '/root/configCode/text()' 2>/dev/null
MacBook Pro (Retina, 15-inch, Mid 2015)
```

#### Virtual Machine

```bash
if sysctl -n machdep.cpu.features | grep -q "VMM"; then
	printf "%s" "VM"
else
	printf "%s" "Not VM"	
fi
```