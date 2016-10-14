# macOS Snippets: dscl 

The following snippets are used to interact with the dscl command on macOS.

## Index

* [UID Highest](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_dscl.md#uid-highest)

## Snippets

### UID Highest

Returns the highest UID in the user database.

**BASH**
```bash
dscl . -list /Users UniqueID | awk '{ if ( uid < $2 ) uid=$2 } END { print uid }'
```

Output:

```console
505
```