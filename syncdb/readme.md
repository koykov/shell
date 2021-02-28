#SyncDB

Selective database syncronization tool.

Provide a possibility to sync only necessary data between two Mysql databases.

## Usage

The tool requires two DSN URL (source and destination) and path the the list file.

Example:
```bash
./syncdb.sh --source "mysql://user0:pass0@host0:port/dbname0" --destination "mysql://user1:pass1@host1:port/dbname1" --list-file path/to/list/file
```

Options `--source`, `--destination` and `list-file` has shorthand aliases: `-s`, `-d` and `-l`.

## Syntax

List file has primitive syntax - each line nas left and right side with using `:` as separator. Left side contains the name of table in source DB (also you may specify database name as `<dbname>.<tablename>`).

Right side contains `select` script that will used as source dataset to import to destination db. So that you may specify only necessary columns to import. If you need to import the whole table just specify `*` in the right side.
