#!/bin/bash

### Version 1.0.0
### Created by Erik Berglund
### https://github.com/erikberglund

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### DESCRIPTION
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# This script loops through all current network services.
# It creates a new list with the prioritized services at the top.
# Then it updates the network service order with the new list.

# This is a combination of an old script I had laying around, and a discussion on macadmins.slack.com
# Where @bskillets asked about using awk to create a correct service list and @pmbuko provided the awk regex.
# User @elvisizer also added a deprioritizedServices array to move services to the end of the service order.

#//////////////////////////////////////////////////////////////////////////////////////////////////
###
### MAIN SCRIPT
###
#//////////////////////////////////////////////////////////////////////////////////////////////////

# Loop through all network services and separate prioritized services from other services.
while read networkService; do
	if [[ ${networkService} =~ .*Ethernet.* ]] || [[ ${networkService} =~ .*Thunderbolt.* ]]; then
		prioritizedServices+=( "${networkService}" )
	elif [[ ${networkService} =~ .*Bluetooth.* ]] || [[ ${networkService} =~ .*FireWire.* ]]; then
		deprioritizedServices+=( "${networkService}" )
	else
		otherServices+=( "${networkService}" )
	fi
done < <( networksetup -listnetworkserviceorder | awk '/^\([0-9]/{$1 ="";gsub("^ ","");print}' )

# Update network service order with prioritized services at the top.
networksetup -ordernetworkservices "${prioritizedServices[@]}" "${otherServices[@]}" "${deprioritizedServices[@]}"

exit 0
