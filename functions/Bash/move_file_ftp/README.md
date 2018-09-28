# move\_file\_ftp

Move a file on an ftp server, creating target directory if it doesn't exist

**Important**: No leading slash in ftp paths! (might add a check/fix later).

## Usage

```bash
move_file_ftp "${ftp_path_file_1}" "${ftp_path_file_2}"
```