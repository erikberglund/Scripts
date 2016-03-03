#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Prints all current dhcp-options for selected interface

# Example Output:
# Option 1: 255.255.255.0
# Option 3: 172.16.98.1
# Option 6: 172.16.98.1
# Option 15: bredbandsbolaget.se
# ...

# Example Output with -n
# Option 1 (subnet_mask): 255.255.255.0
# Option 3 (router): 172.16.98.1
# Option 6 (domain_name_server): 172.16.98.1
# Option 15 (domain_name): bredbandsbolaget.se

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### USAGE
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Usage: ./printDHCPOptions.bash [options] <argv>...
#
# Options:
#  -i		(Optional) Interface Name (en0, en1...)
#  -n		(Optional) Print option code names

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

print_usage() {
	printf "\n%s\n\n" "Usage: ./${0##*/} [options] <argv>..."
	printf "%s\n" "Options:"
	printf "  %s\t%s\n" "-i" "(Optional) Interface Name (en0, en1...)"
	printf "  %s\t%s\n" "-n" "(Optional) Print option code names"
	printf "\n"
}

parse_command_line_options() {
	while getopts "i:n" opt; do
		case ${opt} in
			i) interface="${OPTARG}";;
			n) names="true";;
			\?)	print_usage; exit 1 ;;
			:) print_usage; exit 1 ;;
		esac
	done
}

name_for_option() {
	# DHCP options from https://opensource.apple.com/source/xnu/xnu-3248.20.55/bsd/netinet/dhcp_options.h
	case $1 in
		0) name="pad" ;;
		1) name="subnet_mask" ;;
		2) name="time_offset" ;;
		3) name="router" ;;
		4) name="time_server" ;;
		5) name="name_server" ;;
		6) name="domain_name_server" ;;
		7) name="log_server" ;;
		8) name="cookie_server" ;;
		9) name="lpr_server" ;;
		10) name="impress_server" ;;
		11) name="resource_location_server" ;;
		12) name="host_name" ;;
		13) name="boot_file_size" ;;
		14) name="merit_dump_file" ;;
		15) name="domain_name" ;;
		16) name="swap_server" ;;
		17) name="root_path" ;;
		18) name="extensions_path" ;;
		19) name="ip_forwarding" ;;
		20) name="non_local_source_routing" ;;
		21) name="policy_filter" ;;
		22) name="max_dgram_reassembly_size" ;;
		23) name="default_ip_time_to_live" ;;
		24) name="path_mtu_aging_timeout" ;;
		25) name="path_mtu_plateau_table" ;;

		# Unfinished list

		*) name="-" ;;
	esac
	printf "%s" "${name}"
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Parse all passed options
parse_command_line_options "${@}"

for ((i=0; i<256; i++)); do
	option_output=$( ipconfig getoption "${interface}" ${i} )
	if [[ -n ${option_output} ]]; then
		if [[ ${names} == true ]]; then
			option_name="${i} ($( name_for_option ${i} ))"
		fi
		printf "%s\n" "Option ${option_name:-${i}}: ${option_output}"
	fi
done

exit 0
