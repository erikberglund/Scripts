# macOS Snippets: Finder 

The following snippets are used to modify the Finder

### Index

* [Favorite Servers](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_finder.md#favorite-servers)
* [Favorite Servers](https://github.com/erikberglund/Scripts/blob/master/snippets/macos_finder.md#sidebar)

## Favorite Servers

Add a favorite server to the connect to server dialog

**NOTE: sfltool requires OS X 10.11 or later**

**BASH**
```bash
# Adds an entry with only the hostname or IP showing in the dialog
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteServers "smb://192.168.0.1/Share"

# Adds an entry with a custom name ("Company Share") showing in the dialog
/usr/bin/sfltool add-item -n "Company Share" com.apple.LSSharedFileList.FavoriteServers "smb://192.168.0.1/Share"
```

## Sidebar

Add an item in the sidebar

**NOTE: sfltool requires OS X 10.11 or later**

**BASH**
```bash
# Adds an item named "Shared" that points to the folder at /Users/Shared
/usr/bin/sfltool add-item com.apple.LSSharedFileList.FavoriteItems file:///Users/Shared
```

You can also add "-v" at the end for verbose output for the add-item command