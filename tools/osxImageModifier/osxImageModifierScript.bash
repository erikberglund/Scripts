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

#
# EXAMPLES
#

#
# Verify /var/db/.AppleSetupDone exists
#
if [[ ${osx_image} =~ "DBGY-Vagn" ]] && ! [[ -f "${osx_image_mountpoint}/var/db/.AppleSetupDone" ]]; then
    if touch "${osx_image_mountpoint}/var/db/.AppleSetupDone"; then
        osx_image_modified="True"
        printf "%s\n" "Added .AppleSetupDone"
    fi
elif [[ -f "${osx_image_mountpoint}/var/db/.AppleSetupDone" ]]; then
    if rm -f "${osx_image_mountpoint}/var/db/.AppleSetupDone"; then
        osx_image_modified="True"
        printf "%s\n" "Deleted .AppleSetupDone"
    fi
else
    printf "%s\n" "Verified .AppleSetupDone did not exist!"
fi

#
# Remove user
#
username="macsupport"
dscl -f "${osx_image_mountpoint}/var/db/dslocal/nodes/Default" localonly delete "/Local/Default/Users/${username}"
rm -rf "${osx_image_mountpoint}/Users/${username}"

#
# Remove /var/db/.RunLanguageChooserToo if it exists
#
if [[ -f "${osx_image_mountpoint}/var/db/.RunLanguageChooserToo" ]]; then
    if rm -f "${osx_image_mountpoint}/var/db/.RunLanguageChooserToo"; then
        osx_image_modified="True"
        printf "%s\n" "Deleted .RunLanguageChooserToo"
    fi
else
    printf "%s\n" "Verified .RunLanguageChooserToo did not exist!"
fi


#
# Check if image has a recovery partition
#
if (( $( hdiutil pmap "${osx_image}" | awk '/Apple_Boot/ || /Recovery HD/ { print 1 }' ) )); then
    osx_image_has_recovery="YES"
else
    osx_image_has_recovery="NO"
fi
printf "%s\n" "Has Recovery: ${osx_image_has_recovery}"


#
# Check version of Application
#
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
		
		osx_image_modified="True"
    fi
else
    printf "%s\n" "${application_path}: No such file or directory"
fi

# Print if image was modified (and requires saving)
printf "%s\n" "Image Modified: ${osx_image_modified:-False}"