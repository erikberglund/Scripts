## sharedLibraryDependencyChecker

Example:


`-t`: Show dependencies for the `Quartz.framework` binary.
`-v`: Show dependencies missing from the system volume `/Volumes/OS X Base System`
`-x`: Output the result as regexes
`-r`: Show what binary is dependent on the missing dependency
`-f`: Output full path to all dependencies

```bash
sharedLibraryDependencyChecker -t "/System/Library/Frameworks/Quartz.framework/Versions/A/Quartz" -v "/Volumes/OS X Base System" -x -r -f
```