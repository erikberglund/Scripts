# Introduction

Style guide for writing shell scripts in bash

# Index

* [File](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#file)
    * [Shebang](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#shebang)
    * [Extension](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#extension)
* [Comments](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#comments)
* [Naming Conventions](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#naming_conventions)
* [Formatting](https://github.com/erikberglund/Scripts/blob/master/sytelguide/bash.md#formatting)

## File

* ##### Shebang
 Always use the `#!/usr/bin/env bash` shebang.
 
  _This is an example [find](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/find.1.html) command for updating the shebang in <u>executable</u> files with mimetype `text/x-shellscript`:_
  
 ```bash
 find . -type f -perm +111 -exec "${SHELL}" -c '[[ "$( file --brief --mime-type "${1}" )" == 'text/x-shellscript' ]]' $SHELL '{}' \; -exec sed -i '' '1s/bin\/bash$/usr\/bin\/env bash/' '{}' \;
 ```
 
* ##### Extension
 An executable should not have a file extension, therefore it's not recommended.  
 
 If you _need_ to use a file extension, use `.sh`.
 
  _This is an example [find](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/find.1.html) command for removing the file extensions `.sh` and `.bash` from <u>executable</u> files:_
  
 ```bash
 find -E . -type f -perm +111 -iregex '(.*\.sh$|.*\.bash)' -exec "${SHELL}" -c 'mv "${0}" "${0%.*}"' '{}' \;
 ```
 
* ##### Shell Options.
 Always use `set` to set shell options.
 
## Comments

## Naming Conventions

## Formatting