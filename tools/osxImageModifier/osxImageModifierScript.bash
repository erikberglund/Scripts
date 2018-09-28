#
# VARIABLES
#
# The following variables are available to this script:
#
# osx_image                 Path to dmg
# osx_image_mountpoint      Path to dmg r/w mounted volume
# os_version                OS Version
# os_build_version          OS Build

# If any modification was done, remember to set the variable osx_image_modified to True
# Else the script won't write the updated image to output folder.

# Input Variables
#osx_image - Path to the disk image to modify
#osx_image_mountpoint - Path to the disk image mountpoint

# Static Variables
#osx_image_add_recovery="False|True"
#osx_image_modified="False|True"
#osx_image_recreate="False|True"
#osx_image_convert="False|True"
#osx_image_scan="False|True"

#
# MAIN SCRIPT
#

#
# Verify image format is 'UDZO', else convert it
#
if [[ $( hdiutil imageinfo "${osx_image}" | awk '/Format:/ { print $NF }' ) != UDZO ]]; then
    osx_image_convert='True'
fi

#
# Verify image partition scheme is 'GUID', else recreate image
#
if [[ $( hdiutil imageinfo "${osx_image}" | awk '/partition-scheme:/ { print $NF }' ) != GUID ]]; then
    osx_image_recreate='True'
fi

#
# Verify /var/db/.AppleSetupDone exists
#
if ! [[ -f "${osx_image_mountpoint}/var/db/.AppleSetupDone" ]]; then
    if touch "${osx_image_mountpoint}/var/db/.AppleSetupDone"; then
        osx_image_modified='True'
        printf "%s\n" "Added: .AppleSetupDone"
    fi
elif [[ -f "${osx_image_mountpoint}/var/db/.AppleSetupDone" ]]; then
    if rm -f "${osx_image_mountpoint}/var/db/.AppleSetupDone"; then
        osx_image_modified='True'
        printf "%s\n" "Deleted: .AppleSetupDone"
    fi
else
    printf "%s\n" "Verified .AppleSetupDone did not exist!"
fi

#
# Remove /var/db/.RunLanguageChooserToo if it exists
#
if [[ -f "${osx_image_mountpoint}/var/db/.RunLanguageChooserToo" ]]; then
    if rm -f "${osx_image_mountpoint}/var/db/.RunLanguageChooserToo"; then
        osx_image_modified='True'
        printf "%s\n" "Deleted .RunLanguageChooserToo"
    fi
else
    printf "%s\n" "Verified .RunLanguageChooserToo did not exist!"
fi

#
# Check if image has a recovery partition
#
if (( $( hdiutil pmap "${osx_image}" | awk '/Apple_Boot/ || /Recovery HD/ { print 1 }' ) )); then
    osx_image_has_recovery='YES'
else
    osx_image_has_recovery='NO'
    osx_image_add_recovery='True'
    
    # ****** IMPORTANT ****** 
    # Set this variable to a path with a disk image containing a recovery partition you would like to add to the current disk image.
    # ***********************
    recovery_image=""
    if [[ -z ${recovery_image} ]]; then
        printf "%s\n" "**** ERROR ****"
        printf "%s\n" "No path was defined for a disk image containing the recovery partition you want to add"
        exit 1
    fi
fi
printf "%s\n" "Has Recovery: ${osx_image_has_recovery}"

#
# Check if image is imagescanned
#
udif_ordered_chunks=$( /usr/libexec/PlistBuddy -c "Print udif-ordered-chunks" /dev/stdin <<< $( hdiutil imageinfo "${osx_image}" -plist ) )
if [[ ${udif_ordered_chunks} != true ]]; then
    osx_image_scan='True'
    printf "%s\n" "Image have NOT been imagescanned!"
else
    printf "%s\n" "Image is already imagescanned!"
fi

#
# Remove user(s)
#
<<COMMENT
user_list=( "testuser" )
image_node_path="${osx_image_mountpoint}/var/db/dslocal/nodes/Default"
for user in "${user_list[@]}"; do
    if dscl . -read "/Users/${user}" >/dev/null 2>/dev/null; then
        printf "%s\n" "User ${user} exists, removing..."
        user_database_path="/Local/Default/Users/${user}"
        user_home_folder="${osx_image_mountpoint}/$( dscl -f "${image_node_path}" localonly read "${user_database_path}" NFSHomeDirectory | awk -F': ' '{ print $2 }' )"
        if [[ ${user_home_folder} != ${osx_image_mountpoint} ]] && [[ -d ${user_home_folder} ]]; then
            printf "%s\n" "Deleting user home folder at: ${user_home_folder}..."
            if rm -rf "${user_home_folder}"; then
                osx_image_modified='True'
                printf "%s\n" "Deleted: ${user_home_folder}"
            fi
        fi
        
        printf "%s\n" "Deleting user record from database..."
        if dscl -f "${image_node_path}" localonly delete "${user_database_path}"; then
            osx_image_modified='True'
            printf "%s\n" "Deleted user record!"
        else
            printf "%s\n" "Deleting user record FAILED!"
            exit 1
        fi
    else
        printf "%s\n" "User ${user} does NOT exist!"
    fi
done
COMMENT

#
# Check version of Application
#
<<COMMENT
application_name="TeamViewerQS.app"
application_path="${osx_image_mountpoint}/Applications/${application_name}"
if [[ -f "${application_path}/Contents/Info.plist" ]]; then
    application_version=$( /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${application_path}/Contents/Info.plist" 2>&1 )
    printf "%s\n" "${application_name} Version: ${application_version}"
    
    if [[ ${application_version} =~ ^11 ]]; then
        printf "%s\n" "Removing incorrect version..."
        if ! rm -rf "${application_path}"; then
            printf "%s\n" "Removing ${application_path} failed!"
            exit 1
        fi
        
        printf "%s\n" "Copying correct version..."
        application_local_path="/Volumes/Seagate/BTSync/Academedia/Applications_Projects/TeamViewer_QuickSupport/Applications/TeamViewerQS.app"
        if ! cp -R "${application_local_path}" "${application_path}"; then
            printf "%s\n" "Copying ${application_local_path} failed!"
            exit 1
        fi
        
        osx_image_modified='True'
    fi
else
    printf "%s\n" "${application_path}: No such file or directory"
fi
COMMENT

# Print if image was modified (and requires saving)
printf "%s\n" "Image Modified: ${osx_image_modified:-False}"
printf "%s\n" "Image Add Recovery: ${osx_image_add_recovery:-False}"
printf "%s\n" "Image Recreate: ${osx_image_recreate:-False}"
printf "%s\n" "Image Convert: ${osx_image_convert:-False}"
printf "%s\n" "Image Imagescanned: ${osx_image_scan:-False}"