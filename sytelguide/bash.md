# Introduction

Style guide for writing shell scripts in bash

# Index

* [File]()
    * [Shebang]()
    * [Extension]()
* [Comments]()
* [Naming Conventions]()
* [Formatting]()

## File

* ### Shebang
 Always use the `#!/usr/bin/env bash` shebang.
 
  _If you need to do a find and replace of earlier scripts, this is an example find command:_
  
 ```bash
 find . -type f -name *.bash -exec sed -i '' '1s/bin\/bash$/usr\/bin\/env bash/' {} \;
 ```
 
* ### Extension
 An executable file should not have any file extension, therefore it's not recommended.  
 If a file extension must be used, use `.sh`.
 
* ### Shell Options.
 Always use `set` to set shell options...
 
## Comments

## Naming Conventions

## Formatting