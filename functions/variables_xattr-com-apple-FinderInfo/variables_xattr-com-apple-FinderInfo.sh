#!/bin/bash

# Variables for setting the com.apple.FinderInfo extended attributes to items on OS X.

fi_color() {
	# com.apple.FinderInfo attribute label colors
	fi_red="0000000000000000000C00000000000000000000000000000000000000000000" # Red
	fi_grn="0000000000000000000400000000000000000000000000000000000000000000" # Green
	fi_gra="0000000000000000000300000000000000000000000000000000000000000000" # Gray
	fi_pur="0000000000000000000600000000000000000000000000000000000000000000" # Purple
	fi_yel="0000000000000000000B00000000000000000000000000000000000000000000" # Yellow
	fi_ora="0000000000000000000E00000000000000000000000000000000000000000000" # Orange
	
	# Clear ALL com.apple.FinderInfo  attributes
	fi_clr="0000000000000000000000000000000000000000000000000000000000000000" 
	
	# List of available labels
	fi_color_available=( "fi_red"\
                         "fi_grn"\
                         "fi_gra"\
                         "fi_pur"\
                         "fi_yel"\
                         "fi_ora"\
                         "fi_clr"
                        )
}
