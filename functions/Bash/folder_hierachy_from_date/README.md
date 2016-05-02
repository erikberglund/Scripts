# folder_hierachy_from_date

Outputs a folder hierachy from passed (or current if nothing passed) date.  
Date format defaults to YYYY-MM-DD, if passed date has another format, pass a format string for 'date' to convert passed date.

## Usage

```bash
folder_hierachy_from_date "${date_string}" "${date_format_string}"
```

## Example:

```bash
folder_hierachy_from_date  '2016-05-02'
/2016/05/02
```

```bash
folder_hierachy_from_date '1462176024' '%s'
/2016/05/02
```

