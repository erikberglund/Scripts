# macOS Snippets: Network 

The following snippets are used te get networking information.

### Index

* [Active Network Interface](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_network.md#active-network-interface)
* [IP for Network Interface](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_network.md#ip-for-network-interface)
* [Hardware Port for Network Interface](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_network.md#hardware-port-for-network-interface)
* [Renew DHCP Address for Network Interface](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_network.md#renew-dhcp-address-for-network-interface)

## Active Network Interface

Get the currently active (primary) network interface.

**BASH**  
```bash
scutil <<< "show State:/Network/Global/IPv4" | awk '/PrimaryInterface/ { print $NF }'
```

Alternate method:

```bash

```

Output:

```console
en0
```

## IP for Network Interface

Get the primary IP for the passed network interface.

**BASH**
```bash
# Get network interface to check (See 'Active Network Interface' to get current interface)
interface=en0

# Print the IP for the network interface
scutil <<< "show State:/Network/Interface/${interface}/IPv4" | awk '/\ Addresses\ / { getline; print $NF }'
```

Output:

```console
192.168.2.52
```

## Hardware Port for Network Interface

Get the hardware port (Ethernet, Wi-Fi etc.) for the passed network interface.

**BASH**
```bash
# Get network interface to check (See 'Active Network Interface' to get current interface)
interface=en0

# Print the hardware port for the network interface
networksetup -listallhardwareports | awk '/Hardware Port:/ { line = $NF }; /Device: '"${interface}"'/ { print line }'
```

Output:

```console
Ethernet
```

## Renew DHCP Address for Network Interface

Request a new DHCP Address for passed network interface.

**BASH**
```bash
# Get network interface to check (See 'Active Network Interface' to get current interface)
interface=en0

#
sudo scutil <<< "add State:/Network/Interface/${interface}/RefreshConfiguration temporary"
```