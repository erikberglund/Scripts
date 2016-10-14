# macOS Snippets: NetBoot 

The following snippets are used in a NetBoot environment.

## Index

* [Is NetBooted](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_netboot.md#is-netbooted)

## Snippets

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