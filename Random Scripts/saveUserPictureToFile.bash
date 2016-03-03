#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Ouptuts a user's account picture to passed file

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### USAGE
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Usage: ./printDHCPOptions.bash [options] <argv>...
#
# Options:
#  -f		Output file path
#  -u		Username (short)

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

print_usage() {
	printf "\n%s\n\n" "Usage: ./${0##*/} [options] <argv>..."
	printf "%s\n" "Options:"
	printf "  %s\t%s\n" "-f" "Output file path"
	printf "  %s\t%s\n" "-u" "Username (short)"
	printf "\n"
}

parse_command_line_options() {
	while getopts "u:f:" opt; do
		case ${opt} in
			f)
				file="${OPTARG}"
				if [[ ${file##*.} != .jpg ]]; then
					file="${file}.jpg"
				fi
			;;
			u) user="${OPTARG}";;
			\?) print_usage; exit 1 ;;
			:) print_usage; exit 1 ;;
		esac
	done
	
	if [[ -z ${file} ]] || [[ -z ${user} ]]; then
		print_usage; exit 1	
	fi
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Parse all passed command line options
parse_command_line_options "${@}"

# Parse all passed command line options
dscl . -read /Users/"${user}" JPEGPhoto | tail -1 | xxd -r -p > "${file}"