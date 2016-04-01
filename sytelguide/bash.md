Style Guide for writing in bash

* Always use the more portable `#!/usr/bin/env bash` shebang  
 If you need to do a find and replace of earlier scripts, this is an example find command:
 
 ```console
 find . -type f -name *.bash -exec sed -i '' '1s/bin\/bash$/usr\/bin\/env bash/' {} \;
 ```