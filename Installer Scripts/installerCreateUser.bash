#!/bin/bash

### Version 1.0.1
### Created by Erik Berglund

###
### DESCRIPTION
###

# This script is designed to be run from an installer package as a preinstall or a postinstall script.

###
### CHANGE THESE VARIABLES TO MODIFY USER
###

# User short name may only contain the following characters: a-z, A-Z, _ (underscore), - (hyphen), . (period)
# More info here on page 66-67: https://manuals.info.apple.com/MANUALS/1000/MA1181/en_US/UserMgmt_v10.6.pdf
userShortName="user"

userRealName="User"
userPassword="password"

# Path to a picture on target machine, if it doesn't exist at script runtime it will be replaced by a default picture.
userPicture="/Library/User Pictures/Fun/Ying-Yang.png"

# If userIsHidden is set to yes, this will be overridden to "/var/${userShortName}".
# Don't add ${3} before user path, this will be read by the target system when booted.
userHomeDirectory="/Users/${userShortName}"

userUID="999"
userPrimaryGroupID="20"

# Additional groups user should be a member of, separated by semicolon (;) without spaces.
# Don't add group 'admin' here, use "userIsAdmin" setting instead.
userGroups=""

userIsAdmin="yes"
userIsHidden="no"
userAutoLogin="yes"

###
### AUTOMATIC VARIABLES
###

# Set up all variables passed by installer
# More info here on page 50: https://developer.apple.com/legacy/library/documentation/DeveloperTools/Conceptual/SoftwareDistribution4/SoftwareDistribution4.pdf
installerPackagePath="${1}"  # Full path to the installation package the Installer application is processing. Exanoke: 
destinationPath="${2}"       # Full path to the installation destination. Example: /Applications
targetVolumePath="${3}"      # Installation volume (or mountpoint) to receive the payload
rootPath="${4}"              # The root directory for the system. Example: /

# Check that we get a valid volume path as targetVolumePath, else exit.
if [[ -z ${targetVolumePath} ]] || ! [[ -d ${targetVolumePath} ]]; then
	printf "%s\n" "Variable targetVolumePath=${targetVolumePath} is not valid!";
	exit 1
fi

# Get target volume os minor version.
# Minor version is 9 in 10.9.5 for example.
if [[ -f ${3}/System/Library/CoreServices/SystemVersion.plist ]]; then
	targetVolumeOsMinorVersion=$( "${cmd_PlistBuddy}" -c "Print ProductUserVisibleVersion" "${3}/System/Library/CoreServices/SystemVersion.plist" | "${cmd_awk}" -F. '{ print $2 }' 2>&1  )
fi

# Add target volumes' standrad paths to our own PATH
PATH="${3}/usr/bin":"${3}/bin":"${3}/usr/sbin":"${3}/sbin":"$PATH"

# Get path to commands to be used in the script.
cmd_awk=$( which awk )
cmd_dscl=$( which dscl )
cmd_defaults=$( which defaults )
cmd_PlistBuddy="${3}/usr/libexec/PlistBuddy"

# Check that userShortName doesn't contain invalid characters.
if ! [[ ${userShortName} =~ ^[-_.a-zA-Z]+$ ]]; then
	printf "%s\n" "User short name contains invalid characters!"
	printf "%s\n" "userShortName=${userShortName}"
	exit 1
fi

# If userIsAdmin is set to 'yes', add it to the group admin and set it's home directory in /var
if [[ ${userIsAdmin} == yes ]]; then
	if [[ -z ${userGroups} ]]; then
		userGroups="admin"
	else
		userGroups="admin;${userGroups}"
	fi
	
	if [[ ${userIsHidden} == yes ]]; then
		userHomeDirectory="/var/${userShortName}"
	fi
fi

# If no home directory was defined, use the default user home directory path.
if [[ -z ${userHomeDirectory} ]]; then
	userHomeDirectory="/Users/${userShortName}"
fi

# If the selected path for user picture doesn't exist on target volume, add a default picture instead.
if [[ ! -f ${targetVolumePath}/${userPicture} ]]; then
	defaultUserPicture="/Library/User Pictures/Fun/Ying-Yang.png"
	printf "%s\n" "Selected user picture doesn't exist on target volume!"
	printf "%s\n" "userPicture=${userPicture}"
	printf "%s\n" "Will use the default user picture instead: ${defaultUserPicture}"
	userPicture="${defaultUserPicture}"
fi

# Database path to the user to be created.
targetVolumeDatabasePath="/Local/Default/Users/${userShortName}"

###
### MAIN SCRIPT
###

# Create user record
printf "%s\n" "Creating user record in target volume database: ${targetVolumeDatabasePath}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -create "${targetVolumeDatabasePath}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Unable to create user record in target user database"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add RealName
printf "%s\n" "Adding user RealName: ${userRealName}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" RealName "${userRealName}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set RealName"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UniqueID
printf "%s\n" "Adding user UniqueID: ${userUID}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" UniqueID ${userUID} 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UniqueID"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add PrimaryGroup
printf "%s\n" "Adding user PrimaryGroupID: ${userPrimaryGroupID}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" PrimaryGroupID ${userPrimaryGroupID} 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set PrimaryGroup"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add NFSHomeDirectory
printf "%s\n" "Adding user NFSHomeDirectory: ${userHomeDirectory}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" NFSHomeDirectory "${userHomeDirectory}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set NFSHomeDirectory"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UserShell
printf "%s\n" "Adding user UserShell: /bin/bash"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" UserShell '/bin/bash' 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UserShell"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UserPicture
printf "%s\n" "Adding user UserPicture: ${userPicture}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" Picture "${userPicture}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UserShell"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add Password
printf "%s\n" "Adding user Password: *******"
dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -passwd "${targetVolumeDatabasePath}" "${userPassword}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set Password"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add user to selected groups
if [[ -n ${userGroups} ]]; then
	IFS=';' read -ra groupArray <<< "${userGroups}"
	for i in "${groupArray[@]}"; do
		groupName="${groupArray[i]}"
		groupFileName="${groupName}.plist"
		groupFilePath="${targetVolumePath}/var/db/dslocal/nodes/Default/groups/${groupFileName}"
		groupDatabasePath="/Local/Default/Groups/${groupName}"

		if [[ -f ${groupFilePath} ]]; then
			dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${groupDatabasePath}" GroupMembership "${userShortName}" 2>&1 )
			dscl_exit_status=${?}
			if [[ ${dscl_exit_status} -ne 0 ]]; then
				printf "%s\n" "Failed to add user to group: ${groupName}"
				printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
				printf "%s\n" "dscl_output=${dscl_output}"
				exit ${dscl_exit_status}
			fi
		else
			printf "%s\n" "Group ${groupName} does not exist!"
			printf "%s\n" "Skipping group..."
		fi
	done
fi

# Add IsHidden setting
if [[ ${userIsHidden} == yes ]]; then
	printf "%s\n" "Setting user: ${userShortName} as hidden"
	dscl_output=$( "${cmd_dscl}" -f "${targetVolumePath}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" IsHidden 1 )
	dscl_exit_status=${?}
	if [[ ${dscl_exit_status} -ne 0 ]]; then
		printf "%s\n" "Failed to set hidden flag on user: ${userShortName}"
		printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
		printf "%s\n" "dscl_output=${dscl_output}"
		exit ${dscl_exit_status}
	fi
fi

# Add autoLoginUser setting
if [[ ${userAutoLogin} == yes ]]; then
	printf "%s\n" "Setting user: ${userShortName} to log in automatically"
	defaults_output=$( "${cmd_defaults}" write "${targetVolumePath}/Library/Preferences/com.apple.loginwindow.plist" 'autoLoginUser' -string "${userShortName}" 2>&1 )
	defaults_exit_status=${?}
	if [[ ${defaults_exit_status} -ne 0 ]]; then
		printf "%s\n" "Failed to set auto login for user: ${userShortName}"
		printf "%s\n" "defaults_exit_status=${defaults_exit_status}"
		printf "%s\n" "defaults_output=${defaults_output}"
		exit ${defaults_exit_status}
	fi
	
	# Create encoded password for /etc/kcpassword
	# I created a BASH native version from the perl script found here: http://www.brock-family.org/gavin/perl/kcpassword.html
	key=( '125' '137' '82' '35' '210' '188' '221' '234' '163' '185' '31' )
	key_length=${#key}
	userPasswordEncoded=""

	for ((i=0; i<${#userPassword}; i++ )); do
		original_char=$( printf "%d" "'${userPassword:$i:1}" )
		xor_char=$( printf \\$( printf '%03o' $(( original_char ^ ${key[$(( i % key_length ))]} )) ))
		userPasswordEncoded="${userPasswordEncoded}${xor_char}"
	done

	userPasswordEncoded_length=$(( ${#userPasswordEncoded} % 12 ))

	until (( userPasswordEncoded_length == 12 )); do
		key_char=$( printf \\$( printf '%03o' ${key[$(( userPasswordEncoded_length % 12 ))]} ))
		userPasswordEncoded="${userPasswordEncoded}${key_char}"
		userPasswordEncoded_length=$((userPasswordEncoded_length+1))
	done
	
	echo -n "${userPasswordEncoded}" > "${targetVolumePath}/etc/kcpassword"
	"${cmd_chmod}" 0600 "${targetVolumePath}/etc/kcpassword"
fi

printf "%s\n" "Adding user: ${userShortName} was successful!"

exit 0