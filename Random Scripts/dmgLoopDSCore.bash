#!/usr/bin/env bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Loops through all .dmg files (expects DeployStudio installation dmg) in passed path or working directory.
# Extract DSCore binary and does a binary grep to see if it contains a string.

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

function create_temporary_directories {
	mountpoint=$( mktemp -d /private/tmp/dmg.XXXXX ) || error "Unable to create mountpoint"
	extraction_dir=$( mktemp -d /private/tmp/pax.XXXXX ) || error "Unable to create extraction_dir"
}

function remove_temporary_directories {
	
	# If anything is attached to the mountpoint, try to detach it first.
	if diskutil info "${mountpoint}" >/dev/null 2>&1; then
		detach_image
	fi
	
	for dir in "${mountpoint}" "${extraction_dir}"; do
		
		# Remove temporary mountpoint if:
		#   * The variable contains an expected path
		#   * The path exists and is a directory
		if [[ ${dir} =~ ^/private/tmp/(dmg|pax).[a-zA-Z0-9]{5}$ ]] && [[ -d ${dir} ]]; then
			rm -rf "${dir}"
		fi
	done
}

function error {
	printf "%s\n" "$1, exiting script..."; exit 1
}

function parse_opts {
	while getopts "p:" opt; do
		case ${opt} in
			p) path="${OPTARG}"
			;;\?)	printf "%s\n" "Invalid option: -${OPTARG}";;
			:) printf "%s\n" "Option -${OPTARG} requires an argument." ;;
		esac
	done
	
	if [[ -n ${path} ]] && ! [[ -d ${path} ]]; then
		error "${path} is not a directory"
	fi
}

function parse_image {
	
	# Image is attached and mounted at ${mountpoint} when this function is called.
	
	# Get version from the mpkg name, not the best way but seems to be consistent.
	ds_version=$( echo "${mountpoint}"/DeployStudio*.mpkg | sed -nE 's/.*_v?(.*)\.mpkg.*/\1/p' )
	
	# Another weak check, but better to exit here than to try extraction as it probably will fail if the version couldn't be found.
	if [[ -z ${ds_version} ]]; then
		printf "%s\n" "Found no DeployStudio version number, probably not a DeployStudio dmg, ignoring..."	
		return 0
	fi
	
	# Extract DSCore.framework binary to extraction_dir.
	if (cd ${extraction_dir} && gunzip -c "${mountpoint}"/DeployStudio*.mpkg/Contents/Packages/deploystudioAdmin.pkg/Contents/Archive.pax.gz | pax -r -s ":./DeployStudio Admin.app/Contents/Frameworks/DSCore.framework/Versions/A:${extraction_dir}:" "./DeployStudio Admin.app/Contents/Frameworks/DSCore.framework/Versions/A/DSCore"); then
		if grep -q '1YL601802TQ' "${extraction_dir}/DSCore"; then
			printf "%s\n" "DeployStudio version: ${ds_version} - FOUND"
		else
			printf "%s\n" "DeployStudio version: ${ds_version} - NOT FOUND"
		fi
	else
		error "Extracting DSCore failed"
	fi
	
	# Remove the extracted DSCore binary to clean up for next iteration.
	if ! rm "${extraction_dir}/DSCore"; then
		error "Removing DSCore failed"
	fi
}

function detach_image {
	hdiutil detach "${mountpoint}" -force -quiet || error "Detach image failed"
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Parse passed arguments.
parse_opts "${@}"

# Create temporary directories.
create_temporary_directories

# Setup trap to remove temporary direcotries on script exit.
trap remove_temporary_directories INT EXIT
	
# Stop globbing from printing itself if there are no matches.
shopt -s nullglob

# Loop through all .dmg-files found in passed directory (or current working directory if no directory was passed).
for dmg in "${path:-${PWD}}"/*\.dmg; do
		
	# If anything is attached to the mountpoint, try to detach it first.
	if diskutil info "${mountpoint}" >/dev/null 2>&1; then
		detach_image
	fi
		
	# If current dmg is already mounted, exit script and print mountpoint.
	dmg_mountpath=$( hdiutil info -plist | xpath "/plist/dict/key[.='images']/following-sibling::array/dict/key[.='image-path']/following-sibling::string[1][contains(., \"${dmg}\")]/../key[.='system-entities']/following-sibling::array/dict/key[.='mount-point']/following-sibling::string/text()" 2>/dev/null )
	if [[ -n ${dmg_mountpath} ]]; then
		error "Image already mounted at: ${dmg_mountpath}"
	fi
		
	# Attach current dmg at mountpoint
	if hdiutil attach "${dmg}" -noverify -nobrowse -readonly -owners on -mountpoint "${mountpoint}" -quiet; then
		parse_image
		detach_image
	else
		error "Attach image failed"
	fi
done
	
# Restore globbing behaviour.
shopt -u nullglob

exit 0
