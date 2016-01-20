#!/bin/bash

osvers=$( sw_vers -productVersion )
osvers_major=$( /usr/bin/awk -F. '{print $1}' <<< "${osvers}" )
osvers_minor=$( /usr/bin/awk -F. '{print $2}' <<< "${osvers}" )

if [[ ${osvers_major} -ne 10 ]]; then
	printf "%s\n" "Unknown Version of Mac OS X"
elif [[ ${osvers_minor} -lt 11 ]]; then
	printf "%s\n" "System Integrity Protection Not Available For ${osvers}"
elif [[ ${osvers_minor} -ge 11 ]]; then
	sip_output=$( /usr/bin/csrutil status )
	sip_status=$( /usr/bin/awk '/status/ { gsub(/.$/,""); print $5 }' <<< "${sip_output}" )

	if [[ ${sip_status} == "disabled" ]]; then
		printf "%s\n" "System Integrity Protection status: Disabled"
	elif [[ ${sip_status} == "enabled" ]]; then
		printf "%s\n" "System Integrity Protection status: Active"
      
		while read sip_configuration_status; do
			if [[ $( awk '{ print $NF }' <<< "${sip_configuration_status}" ) == disabled ]]; then
				/usr/bin/awk '{ gsub(/^[ \t]+|[ \t]+$/,""); print; }' <<< "${sip_configuration_status}"
			fi
		done < <( /usr/bin/awk '/Configuration/ {flag=1;next} /^$/{flag=0} flag {print}' <<< "${sip_output}" )
	fi
fi
