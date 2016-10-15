# macOS Snippets: Directory Services 

The following snippets are used to interact with the directory services on macOS.

## Index

* [UID Highest](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_directoryservices.md#uid-highest)

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