#!/usr/bin/env bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Recursively create all folders passed to function.
# Exists script if anything prevented folder creation.

# Verifications.
#   If folder path contains ^/Volumes, check that the mountpath exist before creating any folders recursively

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### USAGE
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# create_folder "${path_folder_1}" "${path_folder_2}" ...

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

create_folder() {
    # https://github.com/erikberglund/Scripts/blob/master/functions/Bash/create_folder/create_folder.sh
    for create_folder_folder in "${@}"; do
        
        # If folder path contains a mounted volume, check if volume is mounted before creating folder
        if [[ ${create_folder_folder} =~ ^/Volumes ]]; then
            local create_folder_folder_volume_mountpoint=$( awk -F"/" '{ print "/"$2"/"$3 }' <<< "${create_folder_folder}" )
            if [[ ! -d "${create_folder_folder_volume_mountpoint}" ]]; then
                printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "Unable to create folder: ${create_folder_folder}" >&2
                printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "Mountpoint referenced in target path does not exist" >&2
                exit 1
            fi
        fi
        
        # Check if folder exists, else create it
        if [[ -d ${create_folder_folder} ]]; then
            if [[ -w ${create_folder_folder} ]]; then
                printf "%s %s\n" "[${FUNCNAME}]" "Folder exist and current user ($( /usr/bin/id -un )) have write permissions."
            else
                printf "%s %s\n" "[${FUNCNAME}]" "Folder exist but current user ($( /usr/bin/id -un )) don't have write permissions."
            fi
        
        # Check if folder path exists and is a file, exit with error
        elif [[ -f ${create_folder_folder} ]]; then
            printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "Unable to create folder: ${create_folder_folder}" >&2
            printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "A file already exist at path" >&2
            exit 1
            
        # If passed all checks and folder doesn't exist, create it
        else
            create_folder_mkdir_output=$( /bin/mkdir -p "${create_folder_folder/#\~/$HOME}" 2>&1 )
            if (( ${?} == 0 )); then
                printf "%s %s\n" "[${FUNCNAME}]" "Folder '${create_folder_folder##*/}' was created successfully."
            else
                printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "Error creating folder: ${create_folder_folder}" >&2
                printf "%s %s\n" "[$( basename ${BASH_SOURCE[0]}):${FUNCNAME}:${LINENO}]" "$( /usr/bin/awk -F": " '{ print $3 }' <<< "${create_folder_mkdir_output}" )" >&2
                exit 1
            fi
        fi
    done
}