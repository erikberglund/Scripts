#!/bin/bash

### Version 1.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# This script is designed to remove an installed privileged helper tool for an OS X Applicaton.
# You can either define the helper to remove in this script directly, or pass an OS X Application with the -a option.

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### USAGE
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Usage: ./resetHelper.bash [options] <argv>...
#
# Options:
#  -a		(Optional) Path to application (.app)


#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### VARIABLES
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

helperLaunchdFilename="com.github.NBICreatorHelper.plist"
helperBinaryFilename="com.github.NBICreatorHelper"

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### STATIC VARIABLES
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Setup padding for status messages
paddingCharacter="."
paddingLength="40"
paddingString=$( printf '%0.1s' "${paddingCharacter}"{1..100} )

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

print_usage() {
	printf "\n%s\n\n" "Usage: ./${0##*/} [options] <argv>..."
	printf "%s\n" "Options:"
	printf "  %s\t%s\n" "-a" "(Optional) Path to application (.app)"
	printf "\n"
}

parse_command_line_options() {
	while getopts "a:" opt; do
		case ${opt} in
			a) path_applicationBundle="${OPTARG}";;
			\?)	print_usage; exit 1 ;;
			:) print_usage; exit 1 ;;
		esac
	done
}

printStatusOKForMessage() {
	# Print padding with [OK] at the end
	printf '%*.*s' 0 $(( ${paddingLength} - ${#1} )) "${paddingString}"
	printf " [\e[1;32m%s\e[m]\n" "OK"
	
}

printStatusErrorForMessage() {
	# Print padding with [ERROR] at the end
	printf '%*.*s' 0 $(( ${paddingLength} - ${#1} )) "${paddingString}"
	printf " [\e[1;31m%s\e[m]\n" "ERROR"
}

printError() {
	printf "\t%s\n" "${1}"
}

readHelperFromApplicationBundleAtPath() {

	# Verify passed application bundle path not empty and ends with .app
	if [[ -n ${1} ]] && [[ ${1} =~ .*\.app ]]; then
		local path_applicationBundle="${1}"
	else
		printError "Invalid application bundle path: ${1}"
		exit 1
	fi
	
	if [[ -d ${path_applicationBundle} ]]; then
		
		plistBuddyOutput=$( /usr/libexec/PlistBuddy -x -c "Print SMPrivilegedExecutables:" "${path_applicationBundle}/Contents/Info.plist" 2>&1 )
		plistBuddyExitStatus=${?}
		
		if (( ${plistBuddyExitStatus} != 0 )); then
			printError "Reading 'SMPrivilegedExecutables' from application bundle's Info.plist failed"
			printError "plistBuddyExitStatus=${plistBuddyExitStatus}"
			printError "plistBuddyOutput=${plistBuddyOutput}"
			exit 1
		fi
		
		# Loop through every privileged helper tool defined in application bundle's Info.plist and remove it.
		while read helperBinaryFilename; do
			
			printf "%s\n" "Resetting helper: ${helperBinaryFilename}..."
			
			# Currently assumes the helper launchd plist has the same name as the binary
			helperLaunchdFilename="${helperBinaryFilename}.plist"
			
			# Remove helper launchd plist
			removeHelperLaunchdPlistWithName "${helperLaunchdFilename}"
			
			# Remove helper binary
			removeHelperBinaryWithName "${helperBinaryFilename}"
			
		done < <( /usr/bin/sed -nE 's/<key>(.*)<\/key>/\1/p' <<< "${plistBuddyOutput}" )
	else
		printf "%s\n" "Application bundle at path: "${path_applicationBundle}" does not exist"
		exit 1
	fi

}

removeHelperLaunchdPlistWithName() {
	
	# Verify passed helper launchd plist name is not empty and ends with .plist
	if [[ -n ${1} ]] && [[ ${1} =~ .*\.plist ]]; then
		local path_helperLaunchdPlist="/Library/LaunchDaemons/${1}"
	else
		printError "Invalid helper launchd plist name: ${1}"
		exit 1
	fi
	
	if [[ -f ${path_helperLaunchdPlist} ]]; then
		printf "%s" "Unloading helper launchd plist..."
		
		launchctlUnloadOutput=$( /bin/launchctl unload "${path_helperLaunchdPlist}" 2>&1 )
		launchctlExitStatus=${?}
		
		if (( ${launchctlExitStatus} == 0 )); then
			printStatusOKForMessage "Unloading helper launchd plist..."
		else
			printStatusErrorForMessage "Unloading helper launchd plist..."
			printError "launchctlExitStatus=${launchctlExitStatus}"
			printError "launchctlUnloadOutput=${launchctlUnloadOutput}"
			exit 1
		fi
	
		printf "%s" "Removing helper launchd plist..."
		
		rmOutput=$( /bin/rm "${path_helperLaunchdPlist}" 2>&1 )
		rmExitStatus=${?}
		
		if (( ${rmExitStatus} == 0 )); then
			printStatusOKForMessage "Removing helper launchd plist..."
		else
			printStatusErrorForMessage "Removing helper launchd plist..."
			printError "rmExitStatus=${rmExitStatus}"
			printError "rmOutput=${rmOutput}"
			exit 1
		fi
	else
		printf "%s\n" "Helper launchd plist with name "${helperLaunchdFilename}" is not installed"
	fi
}

removeHelperBinaryWithName() {
	
	# Verify passed helper binary name is not empty
	if [[ -n ${1} ]]; then
		local path_helperBinary="/Library/PrivilegedHelperTools/${1}"
	else
		printError "Invalid helper launchd plist name: ${1}"
		exit 1
	fi
	
	if [[ -f ${path_helperBinary} ]]; then
		printf "%s" "Removing helper binary..."
		
		rmOutput=$( /bin/rm "${path_helperBinary}" 2>&1 )
		rmExitStatus=${?}
		
		if (( ${rmExitStatus} == 0 )); then
			printStatusOKForMessage "Removing helper binary..."
		else
			printStatusErrorForMessage "Removing helper binary..."
			printError "rmExitStatus=${rmExitStatus}"
			printError "rmOutput=${rmOutput}"
			exit 1
		fi
	else
		printf "%s\n" "Helper binary with name "${helperBinaryFilename}" is not installed"
	fi
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

# Parse all passed options
parse_command_line_options "${@}"

if [[ -n ${path_applicationBundle} ]]; then
	
	# Read helper binary name(s) from application bundle Info.plist
	readHelperFromApplicationBundleAtPath "${path_applicationBundle}"
else
	printf "%s\n" "Resetting helper: ${helperBinaryFilename}..."
	
	# Remove hardcoded helper launchd plist
	removeHelperLaunchdPlistWithName "${helperLaunchdFilename}"

	# Remove hardcoded helper binary
	removeHelperBinaryWithName "${helperBinaryFilename}"
fi



exit 0