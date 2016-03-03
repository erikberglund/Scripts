#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# This script loops through all current network services and disabled any whose name doesn't match 
# the regex provided

# This is for a discussion on macadmins.slack.com where @qomsiya wanted to disable all network
# interfaces except Wi-Fi

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### VARIABLES
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Regex for all network service names to keep enabled
network_services_enabled_regex=".*Wi-Fi.*"

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Loop through all active network services and disable any that doesn't match ${network_services_enabled_regex}.
while read networkService; do
	if ! [[ ${networkService} =~ ${network_services_enabled_regex} ]]; then
		networksetup -setnetworkserviceenabled "${networkService}" off
	fi
done < <( networksetup -listnetworkserviceorder | awk '/^\([0-9]/{$1 ="";gsub("^ ","");print}' )

exit 0
