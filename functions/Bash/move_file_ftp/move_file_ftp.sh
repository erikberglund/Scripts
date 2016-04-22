#!/usr/bin/env bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Move a file on an ftp server, creating target directory if it doesn't exist

# Important: No leading slash in ftp paths passed to function!

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### USAGE
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# move_file_ftp "${ftp_path_file_1}" "${ftp_path_file_2}"

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

move_file_ftp() {
    # List current content of target directory (creating it if it doesn't exist)
    curl_output=$( curl --list-only --silent --show-error --ftp-create-dirs --user "${ftp_user}:${ftp_pass}" "ftp://${ftp_server}/${2}/" )
    if (( ${?} != 0 )); then
        printf "%s\n" "Listing contents of ftp target directory '${2}' failed!"
        printf "%s\n" "curl_output=${curl_output}"
        exit 1
    fi
    
    # Check if file already exist in target folder
    if [[ ${curl_output[@]} =~ ${1##*/} ]]; then
        printf "%s\n" "File ${1##*/} already exist in ftp target directory '${2}'"
        exit 1
    fi
    
    # Move file from current directory to target directory
    curl_output=$( curl --quote "RNFR ${1}" --quote "RNTO ${2}/${1##*/}" --user "${ftp_user}:${ftp_pass}" "ftp://${ftp_server}" )
    if (( ${?} != 0 )); then
        printf "%s\n" "Moving file '${1##*/}' to target directory '${2}' failed!"
        printf "%s\n" "curl_output=${curl_output}"
        exit 1
    fi
}