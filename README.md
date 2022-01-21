[![Actions Status](https://github.com/niner/Spreadsheet-ODS/workflows/test/badge.svg)](https://github.com/niner/Spreadsheet-ODS/actions)

NAME
====

Spreadsheet::ODS - Work with Open Document (ODS) spreadsheets.

SYNOPSIS
========

```raku
use Spreadsheet::ODS;
```

DESCRIPTION
===========

Spreadsheet::ODS is ...

AUTHOR
======

Stefan Seifert <nine@detonation.org>

### has Hash $!archive

Map of files in the decompressed archive we read from, if any.

### multi method load

```raku
multi method load(
    Str $file
) returns Spreadsheet::ODS
```

Load an ODS workbook from the file path identified by the given string.

### multi method load

```raku
multi method load(
    IO::Path $file
) returns Spreadsheet::ODS
```

Load an ODS workbook in the specified file.

### multi method load

```raku
multi method load(
    Blob $content
) returns Spreadsheet::ODS
```

Load an ODS workbook from the specified blob. This is useful in the case it was sent over the network, and so never written to disk.

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Stefan Seifert

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

