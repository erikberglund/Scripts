#!/bin/bash

# Variables for setting the com.apple.FinderInfo extended attributes to items on OS X.

fi_color() {
    # com.apple.FinderInfo attribute label colors
    fi_red="0000000000000000000D00000000000000000000000000000000000000000000" # Red
    fi_ora="0000000000000000000F00000000000000000000000000000000000000000000" # Orange
    fi_yel="0000000000000000000B00000000000000000000000000000000000000000000" # Yellow
    fi_grn="0000000000000000000500000000000000000000000000000000000000000000" # Green
    fi_blu="0000000000000000000900000000000000000000000000000000000000000000" # Blue
    fi_pur="0000000000000000000700000000000000000000000000000000000000000000" # Purple
    fi_gra="0000000000000000000300000000000000000000000000000000000000000000" # Gray

    # Clear ALL com.apple.FinderInfo  attributes
    fi_clr="0000000000000000000000000000000000000000000000000000000000000000" 
    
    # List of available labels
    fi_color_available=( "fi_red"\
                         "fi_grn"\
                         "fi_blu"\
                         "fi_gra"\
                         "fi_pur"\
                         "fi_yel"\
                         "fi_ora"\
                         "fi_clr"
                        )
}
