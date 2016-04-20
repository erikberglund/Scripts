## printSIPStatus

Print the current SIP status of the running system.

Reimplementation of [this](https://github.com/rtrouton/rtrouton_scripts/blob/master/rtrouton_scripts/check_system_integrity_protection_status/check_system_integrity_protection_status.sh) script by @rtrouton for a discussion on using temporary files when processing command output.

### Example

```console
./printSIPStatus 
System Integrity Protection status: Active
Apple Internal: disabled
DTrace Restrictions: disabled
```