## modelUTIInfo

This script was mostly a test for parsing plist files in Python.

You can pass a model identifier or model code and get information about:

* Marketing Name
* Model Code (Mobile Devices)
* Icon Path
* Uniform Type Identifier

It's parsing the registered [UTIs](https://developer.apple.com/library/ios/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_conc/understand_utis_conc.html#//apple_ref/doc/uid/TP40001319-CH202-SW1) for apple products found in the following locations:


_Mobile Devices:_

```console
/System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Info.plist
```

_Other Devices:_

```console
/System/Library/CoreServices/CoreTypes.bundle/Contents/Info.plist
```

### Usage

```console
usage: modelUTIInfo.py [-h] [-c MODELCODE] [-i] [-l] [-m MODELID] [-n]
```

### Example

**List all available product modelIDs and their corresponding marketing name:**

```console
./modelUTIInfo.py -l
AirPort4,102, AirPort4,107 = AirPort Express
AirPort5,104, AirPort5,105, AirPort5,108, AirPort5,114, AirPort5,117 = AirPort Extreme
AirPort6,106, TimeCapsule6,106, TimeCapsule6,109, TimeCapsule6,113, TimeCapsule6,116 = Time Capsule
AirPort7,120 = AirPort Extreme
AppleTV1,1 = Apple TV
AppleTV2,1 = Apple TV (2nd generation)
AppleTV3,1 = Apple TV (3rd generation)
AppleTV3,2 = Apple TV (3rd generation Rev A)
AppleTV5,3 = Apple TV
...
```

**Information for modelID (iPhone8,2):**

```console
./modelUTIInfo.py -m iPhone8,2
  Marketing Name: iPhone 6s Plus
       Model IDs: iPhone8,2
     Model Codes: N66AP, N66mAP
 Type Identifier: com.apple.iphone-6s-plus-b9b7ba
    Model Icons: [Rose Gold]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-6s-plus-e4c1b9.icns
                 [Space Grey]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-6s-plus-b9b7ba.icns
                 [Gold]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-6s-plus-e1ccb7.icns
                 [Silver]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-6s-plus-dadcdb.icns
```

**Marketing Name for modelCode (N66mAP):**

```console
./modelUTIInfo.py -c N66mAP -n
iPhone 6s Plus
```

**Available Icons for modelID (iPhone5,4):**

```console
./modelUTIInfo.py -m iPhone5,4 -i
[Blue]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-5c-46abe0.icns
[Pink]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-5c-fe767a.icns
[White]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-5c-f5f4f7.icns
[Green]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-5c-a1e877.icns
[Yellow]: /System/Library/CoreServices/CoreTypes.bundle/Contents/Library/MobileDevices.bundle/Contents/Resources/com.apple.iphone-5c-faf189.icns
```