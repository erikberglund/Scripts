#!/bin/bash

# Check if cups printer sharing is enabled on computer

# Possible results: Enabled / Disable

printf "%s%s%s\n" "<result>" "$( cupsctl | awk -F'=' '/_share_printers/ { if ($NF > 0) print "Enabled"; else print "Disabled" }' )" "</result>"

exit 0