#!/bin/bash

### Version 1.0
### Created by Erik Berglund

###
### DESCRIPTION
###


# userIsHidden flag only works on OS X Yosemite or higher.

###
### CHANGE THESE VARIABLES TO MODIFY USER
###


userShortName="user"					
userRealName="User"					
userPassword="password"					

# Path to a picture on target machine, if it doesn't exist at script runtime it will be replaced by a default picture
userPicture="/Library/User Pictures/Fun/Ying-Yang.png"	

# If userIsHidden is set to yes, this will be overridden to "/var/${userShortName}".
userHomeDirectory="/Users/${userShortName}"

userUID="999"
userPrimaryGroupID="20"						

# Additional groups user should be a member of, separated by semicolon without spaces. 
# Don't add group 'admin' here, use "userIsAdmin" setting instead.
userGroups="" 	

userIsAdmin="yes"
userIsHidden="no"
userAutoLogin="yes"

###
### AUTOMATIC VARIABLES
###

targetVolume="${3}"

if [[ -z ${targetVolume} ]] || ! [[ -d ${targetVolume} ]]; then
    printf "%s\n" "Variable targetVolume=${targetVolume} is not valid!";
    exit 1
fi

targetVolumeDatabasePath="/Local/Default/Users/${userShortName}"

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

defaultUserPicture="/Library/User Pictures/Fun/Ying-Yang.png"

if [[ ! -f ${targetVolume}/${userPicture} ]]; then
	printf "%s\n" "Selected user picture doesn't exist on target volume!"
	printf "%s\n" "userPicture=${userPicture}"
	printf "%s\n" "Will use the default user picture instead: ${defaultUserPicture}"
	userPicture="/Library/User Pictures/Fun/Ying-Yang.png"
fi

cmd_dscl="$( which dscl )"
cmd_defaults="$( which defaults )"

###
### MAIN SCRIPT
###

# Create user record
printf "%s\n" "Creating user record in target user database: ${targetVolumeDatabasePath}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -create "${targetVolumeDatabasePath}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Unable to create user record in target user database"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add RealName
printf "%s\n" "Adding user RealName: ${userRealName}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" RealName "${userRealName}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set RealName"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UniqueID
printf "%s\n" "Adding user UniqueID: ${userUID}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" UniqueID ${userUID} 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UniqueID"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add PrimaryGroup
printf "%s\n" "Adding user PrimaryGroupID: ${userPrimaryGroupID}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" PrimaryGroupID ${userPrimaryGroupID} 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set PrimaryGroup"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add NFSHomeDirectory
printf "%s\n" "Adding user NFSHomeDirectory: ${userHomeDirectory}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" NFSHomeDirectory "${userHomeDirectory}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set NFSHomeDirectory"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UserShell
printf "%s\n" "Adding user UserShell: /bin/bash"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" UserShell '/bin/bash' 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UserShell"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add UserPicture
printf "%s\n" "Adding user UserPicture: ${userPicture}"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" Picture "${userPicture}" 2>&1 )
dscl_exit_status=${?}
if [[ ${dscl_exit_status} -ne 0 ]]; then
	printf "%s\n" "Failed to set UserShell"
	printf "%s\n" "dscl_exit_status=${dscl_exit_status}"
	printf "%s\n" "dscl_output=${dscl_output}"
	exit ${dscl_exit_status}
fi

# Add Password
printf "%s\n" "Adding user Password: *******"
dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -passwd "${targetVolumeDatabasePath}" "${userPassword}" 2>&1 )
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
		groupFilePath="${targetVolume}/var/db/dslocal/nodes/Default/groups/${groupFileName}"
		groupDatabasePath="/Local/Default/Groups/${groupName}"

		if [[ -f ${groupFilePath} ]]; then
			dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${groupDatabasePath}" GroupMembership "${userShortName}" 2>&1 )
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
	dscl_output=$( "${cmd_dscl}" -f "${targetVolume}/var/db/dslocal/nodes/Default" localonly -append "${targetVolumeDatabasePath}" IsHidden 1 )
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
	defaults_output=$( "${cmd_defaults}" write "${targetVolume}/Library/Preferences/com.apple.loginwindow.plist" 'autoLoginUser' -string "${userShortName}" 2>&1 )
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
	
	echo -n "${userPasswordEncoded}" > "${targetVolume}/etc/kcpassword"
	"${cmd_chmod}" 0600 "${targetVolume}/etc/kcpassword"
fi

printf "%s\n" "Adding user: ${userShortName} was successful!"

exit 0