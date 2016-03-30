#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Inspect all privileged helper tools installed in /Library/PrivilegedHelperTools and print info
# about their installation status.

# DISCLAIMER:
# This script is in no way a complete or recommended way to determine helper tool status.
# It's just written to illustrate one possible way to inspect helpers and determine if they could/should be removed.

# See my accompanying blog post here: http://erikberglund.github.io/2016/PrivilegedHelperTools_Left_Behind/

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

sgr_variables() {
	# Colors
	red=$(tput setaf 1)	# Red
	yel=$(tput setaf 3)	# Yellow
	def=$'\e[39m'		# Default (Foreground Color)
	
	# Attributes
	bld=$(tput bold)	# Acctivate Bold
	nobld=$'\e[22m'		# Deactivate Bold
	
	# Clear
	clr=$(tput sgr0)	# Deactivate ALL sgr attributes and colors
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS - PLIST
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

parse_plist_info_launchctl() {
	
	# Remove previous variables
	unset plist_info_error; unset helper_bundle_id; unset helper_bundle_name; unset helper_bundle_version; unset helper_application_bundle_ids
	
	# Try to retrieve the embedded Info.plist from the helper binary
	plist_info_launchctl=$( launchctl plist __TEXT,__info_plist "${1}" 2>&1 )
	
	# Get helper info from it's info plist
	if [[ -n ${plist_info_launchctl} ]] && ! [[ ${plist_info_launchctl} =~ "does not have a __TEXT,__info_plist or is invalid."$ ]]; then
		helper_bundle_id=$( awk -F'"' '/CFBundleIdentifier/ { print $(NF-1) }' <<< "${plist_info_launchctl}" )
		helper_bundle_name=$( awk -F'"' '/CFBundleName/ { print $(NF-1) }' <<< "${plist_info_launchctl}" )
		helper_bundle_version=$( awk -F'"' '/CFBundleVersion/ { print $(NF-1) }' <<< "${plist_info_launchctl}" )
		while read -a smauthorizedclient_string; do
			helper_application_bundle_ids+=( $( awk '/identifier$/ { getline; print }' <( printf '%s\n' "${smauthorizedclient_string[@]}" ) ) )
		done < <( awk '/SMAuthorizedClients/ { flag=1; next } /\)\;/ { flag=0 } flag { print }' <<< "${plist_info_launchctl}" | sed 's/[="()]//g' )
	else
		plist_info_error="${plist_info_launchctl}"
	fi
}

parse_plist_launchd_launchctl() {
	
	# Remove previous variables
	unset plist_launchd_error; unset helper_launchd_state; unset helper_launchd_label; unset helper_launchd_path
	
	# Try to retrieve the embedded Launchd.plist from the helper binary
	plist_launchd_launchctl=$( launchctl plist __TEXT,__launchd_plist "${1}" 2>&1 )

	if [[ -n ${plist_launchd_launchctl} ]] && ! [[ ${plist_launchd_launchctl} =~ "does not have a __TEXT,__launchd_plist or is invalid."$ ]]; then
		
		# Get launchd label from extracted plist.
		helper_launchd_label=$( awk -F'"' '/Label/ { print $(NF-1) }' <<< "${plist_launchd_launchctl}" )
		
		# Call 'launchctl print' to get launchd job status
		if [[ -n ${helper_launchd_label} ]]; then
			while read line; do
				if [[ ${line} =~ ^state ]]; then
					helper_launchd_state=$( awk -F= '{ gsub(/ /, ""); print $2 }' <<< "${line}" )
				elif [[ ${line} =~ ^path ]]; then
					helper_launchd_path=$( awk -F= '{ gsub(/ /, ""); print $2 }' <<< "${line}" )
				elif [[ ${line} =~ ^program ]]; then
					helper_launchd_program=$( awk -F= '{ gsub(/ /, ""); print $2 }' <<< "${line}" )
				fi
			done < <( launchctl print system/"${helper_launchd_label}" | grep '\tstate\|\tpath\|\tprogram' )
			
			# Sanity check so that the helper binary path is the same that's used as the program path in the launchd job
			if [[ -n ${helper_launchd_program} ]] && [[ ${helper_launchd_program} != ${helper_path} ]]; then
				printf "\n%s\n\n" "${bld}Current helpers path and path in launchd job is not matching!${clr}"
			fi
		fi
	else
		plist_launchd_error=${plist_launchd_launchctl}
	fi	
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS - PRINT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

print_title() {
	printf "\n%22s%s\n" "[${1}]"
}

print_helper() {
	print_title "Helper"
	
	if [[ -z ${plist_launchd_error} ]]; then
		printf "%22s\t%s\n\n" "Path:" "${helper_path}"
		printf "%22s\t%-10s%s\n" "" "BundleID:" "${helper_bundle_id}"
		printf "%22s\t%-10s%s\n" "" "Name:" "${helper_bundle_name}"
		printf "%22s\t%-10s%s\n" "" "Version:" "${helper_bundle_version}"
	else
		printf "%22s\t%s\n" "Path:" "${helper_path}"
		printf "%22s\t%s\n" "Warning:" "${bld}${plist_info_error}${clr}"
	fi
}

print_helper_launchd() {
	print_title "Launchd"
	
	if [[ -z ${plist_launchd_error} ]]; then
		printf "%22s\t%s\n\n" "Path:" "${helper_launchd_path}"
		printf "%22s\t%-10s%s\n" "" "Label:" "${helper_launchd_label}"
		printf "%22s\t%-10s%s\n" "" "State:" "${helper_launchd_state}"
	else
		printf "%22s\t%s\n" "Warning:" "${bld}${plist_launchd_error}${clr}"
	fi
}

print_helper_authorizationdb() {
	print_title "Authorization DB"
	
	rule_count=0
	for bundle_id in ${helper_application_bundle_ids[@]} ${helper_bundle_id:-${helper_launchd_label}}; do
		while read helper_authorizationdb_rule_name; do
			((rule_count++))
			if (( rule_count == 1 )); then
				printf "%22s\t%s\n" "Rules:" "${helper_authorizationdb_rule_name}"
			else
				printf "%22s\t%s\n" "" "${helper_authorizationdb_rule_name}"
			fi
		done < <( sqlite3 /var/db/auth.db "SELECT name FROM rules WHERE identifier = '${bundle_id}'"; )
	done
	
	# Print out explicit info that no authorization db rules were found.
	if (( rule_count == 0 )); then
		printf "%22s\t%s\n" "Info:" "<No AuthorizationDB Rules Found>"
	fi
}

print_helper_application() {
	print_title "Applications"
	
	application_found='False'
	for helper_application_bundle_id in ${helper_application_bundle_ids[@]}; do
		if [[ -n ${helper_application_bundle_id} ]]; then
			printf "%22s\t%s\n" "BundleID:" "${helper_application_bundle_id}"
			application_count=0
			while read helper_application_path; do
				application_found='True'
				((application_count++))
				helper_application_name=$( /usr/libexec/PlistBuddy -c "Print :CFBundleName" "${helper_application_path}/Contents/Info.plist" )
				helper_application_version=$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${helper_application_path}/Contents/Info.plist" )
				print_helper_application_info
			done < <( mdfind "kMDItemCFBundleIdentifier == ${helper_application_bundle_id}" )
		
			# Print warning if no application matching the current bundle identifiers could
			if (( application_count == 0 )); then
				printf "%22s\t%s\n" "" "<No application with bundle id: '${helper_application_bundle_id}' found>"
			fi
		else
			printf "%s\n" "Empty BundleID"
		fi
	done
	
	# Print error if no application matching any of the bundle identifiers entered in the helper tool's SMAuthorizedClients array
	if [[ ${application_found} != True ]]; then
		print_helper_left_behind
	fi
}

print_helper_application_info() {
	printf "\n"
	printf "%22s\t%-10s%s\n" "" "Name:" "${helper_application_name}"
	printf "%22s\t%-10s%s\n" "" "Path:" "${helper_application_path}"
	printf "%22s\t%-10s%s\n\n" "" "Version:" "${helper_application_version}"
}

print_helper_info() {
	printf "\n"
	printf "%0.1s" "*"{1..80}
	printf "\n"
	
	print_helper
	print_helper_launchd
	if [[ -z ${plist_info_error} ]]; then
		print_helper_authorizationdb
		print_helper_application
	fi
}

print_helper_left_behind() {
	printf "\n"
	printf "${red}%22s\t%s${clr}\n" "" "+------------------------------------------------------+"
	printf "${red}%22s\t%s${clr}\n" "" "|                    !!! WARNING !!!                   |"
	printf "${red}%22s\t%s${clr}\n" "" "|                                                      |"
	printf "${red}%22s\t%s${clr}\n" "" "|    NO APPLICATION FOUND FOR PRIVILEGED HELPER TOOL   |"
	printf "${red}%22s\t%s${clr}\n" "" "|                                                      |"
	printf "${red}%22s\t%s${clr}\n" "" "|               IT  MIGHT BE LEFT BEHIND               |"
	printf "${red}%22s\t%s${clr}\n" "" "+------------------------------------------------------+"
	printf "\n"
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Verify script is run with administrator privileges
if [[ ${EUID} -ne 0 ]]; then
	printf "%s\n" "This script must be run as root!" 1>&2
	exit 1
fi

# Load variables
sgr_variables

# Loop through all binary files directly under "/Library/PrivilegedHelperTools"
for helper_path in /Library/PrivilegedHelperTools/*; do
	if [[ -n ${helper_path} ]] && [[ -f ${helper_path} ]]; then
				
		# Extract and parse embedded plist files from helper at 'helper_path'
		parse_plist_info_launchctl "${helper_path}"
		parse_plist_launchd_launchctl "${helper_path}"
		
		# Print all available info for current helper tool to stdout
		print_helper_info
	else
		printf "\n"
		printf "%0.1s" "*"{1..80}
		printf "\n"
		
		printf "%s\n" "${helper_path} is not a file"
	fi
done

exit 0