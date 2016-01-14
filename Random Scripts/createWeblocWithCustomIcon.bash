#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# This creates a clickable file that opens the selected URL in the user's default browser
# Optionally you may also choose a custom .icns-file to use as file icon

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### VARIABLES
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

## URL for the webloc
webloc_url="https://google.com"

## File name for the webloc (This is the name without a file extension i.e. don't add .webloc to the name)
webloc_name="Google"

## Folder where the webloc should be created
webloc_folder_path="/Users/erikberglund/Desktop"

## Custom icon to use for the webloc
webloc_icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ProfileBackgroundColor.icns"

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

## Create webloc path from script variables
webloc_path="${webloc_folder_path}/${webloc_name}.webloc"

## Create the webloc
/usr/libexec/PlistBuddy -c "Add :URL string ${webloc_url}" "${webloc_path}" > /dev/null 2>&1

if [[ -n ${webloc_icon} ]]; then
	
	## Set icns as icon for the webloc
	python - "${webloc_icon}" "${webloc_path}"<< END
	import Cocoa 
	import sys
	Cocoa.NSWorkspace.sharedWorkspace().setIcon_forFile_options_(Cocoa.NSImage.alloc().initWithContentsOfFile_(sys.argv[1].decode('utf-8')), sys.argv[2].decode('utf-8'), 0) or sys.exit("Unable to set file icon")
	END
fi

## Hide .webloc file extension and tell file it's using a custom icon
## NOTE: SetFile is only available on systems with developer tools installed, should add a check for that if wanting to hide the file extension
# /usr/bin/SetFile -a CE "${webloc_path}"

exit 0