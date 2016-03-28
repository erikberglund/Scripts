#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Reconnects to specified Wi-Fi network if netork changes and it's in range
# Used in our stores to force computers to the store Wi-Fi, but if stolen allows connection to
# any wifi if the store network isn't in range.

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### VARIABLES
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Number of tries to enable Wi-Fi power (Default 10)
wifi_power_max_tries="5"

# Number of tries to connect to Wi-Fi network (Default 10)
wifi_network_max_tries="5"

# SSID to try and connect to
wifi_network_ssid=""

# Password to selected SSID
# It's possible to use the keychain, but then you would have to enable access to the wifi password for this script first,
# or create it using the same script. I haven't covered that in this script, but have used that technique before
wifi_network_password=""

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### FUNCTIONS
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

wifi_power() {
	counter=0
	until [[ $( current_wifi_power_state ) == ${1} ]]; do
		if (( ${wifi_power_max_tries:-10} <= ${counter} )); then
			printf "%s\n" "Could not enable Wi-Fi power on interface ${wifi_interface}"; exit 1
		fi
		/usr/sbin/networksetup -setairportpower "${wifi_interface}" "${1}"
		sleep 2
		counter=$((${counter}+1))
	done
}

current_wifi_power_state() {
	printf "%s" "$( /usr/sbin/networksetup -getairportpower ${wifi_interface} | awk '{ print tolower($NF) }' )"
}

wifi_network() {
	counter=0
	until [[ $( current_wifi_network ) == ${1} ]]; do
		if (( ${wifi_network_max_tries:-10} <= ${counter} )); then
			printf "%s\n" "Could not connect to network with ssid: ${1}"; exit 1
		fi
		/usr/sbin/networksetup -setairportnetwork "${wifi_interface}" "${1}" "${wifi_network_password}"
		sleep 2
		counter=$((${counter}+1))
	done
}

current_wifi_network() {
	printf "%s" "$( /usr/sbin/networksetup -getairportnetwork ${wifi_interface} | awk -F"Network: " '{ print $2 }' )"
}

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

if [[ -z ${wifi_network_ssid} ]]; then
	printf "%s\n" "No SSID selected"	
fi

# Get first Wi-Fi interface (enX)
wifi_interface=$( networksetup -listallhardwareports | awk '/.*Wi-Fi.*/ { getline; print $NF; exit; }' )
if [[ -z ${wifi_interface} ]]; then
	printf "%s\n" "Could not get Wi-Fi hardware interface"; exit 1
fi

# Activate Wi-Fi power if it's off
wifi_power on

# Connect to ${wifi_network_ssid} if it's in range
wifi_network ${wifi_network_ssid}

exit 0