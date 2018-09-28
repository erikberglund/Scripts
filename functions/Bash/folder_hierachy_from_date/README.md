# folder_hierachy_from_date

Outputs a folder hierachy from passed (or current if nothing passed) date.

* Date format defaults to YYYY-MM-DD
* If passed date is not in the default format, pass a format string for use by the `date` command.

## Usage

```bash
folder_hierachy_from_date "${date_string}" "${date_format_string}"
```

## Example:

```bash
folder_hierachy_from_date '2016-05-02'
/2016/05/02
```

```bash
folder_hierachy_from_date '1462176024' '%s'
/2016/05/02
```

