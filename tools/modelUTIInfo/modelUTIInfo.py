#!/usr/bin/env python

import argparse
import plistlib
import re
import sys
import subprocess
from subprocess import Popen, PIPE

mobile_devices_info_plist="/System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Info.plist"
mobile_devices_resources="/System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources"

mac_devices_info_plist="/System/Library/CoreServices/CoreTypes.bundle/Contents/Info.plist"
mac_devices_resources="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources"

model_id_regex=re.compile("^[a-zA-Z]+[0-9]+?,?[0-9]+?($|@.*)")

devices=[]

class device:
	def __init__(self, device_type, marketing_name, model_icons, type_identifier, model_ids, model_codes):
		self.device_type = device_type
		self.model_icons = model_icons
		self.marketing_name = marketing_name
		self.model_type_identifier = type_identifier
		self.model_ids = model_ids
		self.model_codes = model_codes

def get_devices():

	for plist in [ mobile_devices_info_plist, mac_devices_info_plist ]:
	
		# Convert binary plist and store it in mdplist
		xmlplist = plistlib.readPlistFromString(subprocess.Popen(["plutil", "-convert", "xml1", "-o", "-", plist], stdout=PIPE).communicate()[0])

		if plist == mobile_devices_info_plist:
			device_type = "mobile"
			device_resources = mobile_devices_resources
		elif plist == mac_devices_info_plist:
			device_type = "mac"
			device_resources = mac_devices_resources

		# Loop through all dicts in 'UTExportedTypeDeclarations'
		for device_dict in xmlplist["UTExportedTypeDeclarations"]:

			# Only continue if an entry in [...]:UTTypeTagSpecification:com.apple.device-model-code exists
			if device_dict.get("UTTypeTagSpecification", {}).get("com.apple.device-model-code", []):

				model_ids = []
				model_codes = []
				color_name = ""
				add_device = True

				# Loop through all model codes and add to class
				for model_code in device_dict.get("UTTypeTagSpecification", {}).get("com.apple.device-model-code", []):
					if model_id_regex.match(model_code):
						model_ids.append(model_code)
					elif model_code not in ['iPhone', 'iPod', 'iPad', 'Watch', 'AppleTV']:
						model_codes.append(model_code)

				# Get color name from the icon path
				icon_path = device_dict.get("UTTypeIconFile", "")
				if icon_path:
					color_name = color_from_icon_path(icon_path)

				# Loop through all added devices if device info info already exist
				for d in devices:
					if d.model_ids == model_ids and d.model_codes == model_codes:
						add_device = False
						if d.model_icons:
							d.model_icons[color_name] = device_resources + "/" + device_dict.get("UTTypeIconFile", "")
						else:
							d.model_icons = { color_name : device_resources + "/" + device_dict.get("UTTypeIconFile", "")}
						break

				# If add_devices is 'True' and Model ID has been set, add device to list
				if add_device and model_ids:
					devices.append(device(device_type, device_dict.get("UTTypeDescription", ""), { color_name : device_resources + "/" + device_dict.get("UTTypeIconFile", "")}, device_dict.get("UTTypeIdentifier", ""), model_ids, model_codes))

def color_from_icon_path(icon_path):	
	if any(color in icon_path for color in ["black", "3b3b3c"]):
		return "Black"
	elif any(color in icon_path for color in ["white", "e1e4e3", "f5f4f7"]):
		return "White"
	elif any(color in icon_path for color in ["e4c1b9"]):
		return "Rose Gold"
	elif any(color in icon_path for color in ["e1ccb5", "e1ccb7", "d4c5b3"]):
		return "Gold"
	elif any(color in icon_path for color in ["dadcdb", "d7d9d8"]):
		return "Silver"
	elif any(color in icon_path for color in ["b4b5b9", "b9b7ba", "99989b"]):
		return "Space Grey"
	elif any(color in icon_path for color in ["faf189"]):
		return "Yellow"
	elif any(color in icon_path for color in ["fe767a"]):
		return "Pink"
	elif any(color in icon_path for color in ["a1e877"]):
		return "Green"
	elif any(color in icon_path for color in ["46abe0"]):
		return "Blue"
	else:
		return ""

def main(argv):

	# Parse input arguments
	parser = argparse.ArgumentParser()
	parser.add_argument('-c', '--modelcode', type=str)
	parser.add_argument('-i', '--icon', action='store_true')
	parser.add_argument('-l', '--list', action='store_true')
	parser.add_argument('-m', '--modelid', type=str)
	parser.add_argument('-n', '--name', action='store_true')
	args = parser.parse_args()

	# Generate list of devices
	get_devices()

	# If option '-m' (Model ID) or '-c' (Model Code) is passed, only print info for that model
	if args.modelid or args.modelcode:
		
		found_devices = []

		# Add all devices matching passed id or code
		for device in devices:
			if args.modelid:
				if args.modelid.lower() in (model_id.lower() for model_id in device.model_ids ):
					found_devices.append(device)
			elif args.modelcode:
				if args.modelcode.lower() in (model_code.lower() for model_code in device.model_codes ):
					found_devices.append(device)

		# Loop through all matched devices and print their info
		if found_devices:
			for idx, device in enumerate(found_devices):

				# If option '-n' (Marketing Name) was used with a modelid or modelcode, only print the marketing name(s)
				if args.name is True:
					print device.marketing_name
					break

				# If option '-i' (Icon) was used with a modelid or modelcode, only print the icon path(s)
				elif args.icon is True:
					for key in device.model_icons:
						print "[" + key + "]: " + device.model_icons[key]
					break

				# If no special option except model id or model code was passed, print all info for found devices
				else:
					if idx == 0 and 1 < len(found_devices):
						print '-' * 17

					# Markting Name
					print '%18s' % "Marketing Name: " + device.marketing_name

					# Model IDs
					print '%18s' % "Model IDs: " + ', '.join(device.model_ids)

					# Model Codes
					if device.device_type is "mobile":
						print '%18s' % "Model Codes: " + ', '.join(device.model_codes)

					# Type Identifier
					print '%18s' % "Type Identifier: " + device.model_type_identifier

					# Model Icons
					for cidx, key in enumerate(device.model_icons):
						if cidx == 0:
							print '%18s' % "Model Icons: [" + key + "]: " + device.model_icons[key]
						else:
							print '%18s' % "[" + key + "]: " + device.model_icons[key]

					if 1 < len(found_devices):
						print '-' * 17

		# If no device was found, print error
		else:
			if args.modelid:
				print >> sys.stderr, "No device with model identifier: " + args.modelid + " was found"
			elif args.modelcode:
				print >> sys.stderr, "No device with model code: " + args.modelcode + " was found"

	# If option '-l' us used, print all devices and their "Marketing Name"
	elif args.list:
		unique_devices = []
		for device in devices:
			if ', '.join(device.model_ids) + " = " + device.marketing_name not in unique_devices:
				unique_devices.append(', '.join(device.model_ids) + " = " + device.marketing_name)
		print("\n".join(sorted(unique_devices)))

if __name__ == "__main__":
    main(sys.argv[1:])