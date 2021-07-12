#!/usr/bin/env bash

#
# Selective database copy tool.
# Usage:
# ./syncdb.sh --source "mysql://user0:pass0@host0:port/dbname0" --destination "mysql://user1:pass1@host1:port/dbname1" --list-file path/to/list/file
# Shorthand available for the options:
# * -s for --source
# * -d for --destination
# * -l for --list-file
#
# Please note, only DSN URL are allowed for both source and destination databases.
#
# Each line in the List file describes copy rules for one table and has the following format:
# [<db_name>].<table name>:<select_query>
# ":" is a separator. Left side describes table (and optionally database) name. If you omit database name, will be used
# value from the DSN URL. Right side contains Mysql's select query, that should contains exact fields list between
# "select" and "from" keywords. No more requirements for the query.
# If you want to copy the whole table you may put symbol "*" instead of the whole select query.
#
# What you can expect: when you provide select query with exact list of the fields in the table in destination database
# will filled only that fields. All other fields will fill by NULL or it's default values.
# Thereby you can reduce destination table size and have only necessary data from the source database.
#
# What you also should know: this tool may break data consistency in the destination table. All foreign keys will
# removed and all autoincrement fields will convert to simple int fields. That's a payment for reducing database size.
#


# parse dsn url
# return 0 if successful, non-zero in any other cases
function dsn_url_parse {
    dsn_url=$1
    if [[ -z "$dsn_url" ]]; then
        return 1
    fi
    schm="$(echo ${dsn_url} | sed -nr 's,^(.*://).*,\1,p')"
    rest="$(echo ${dsn_url/$schm/})"
    schm="$(echo ${schm} | tr -d :/)"

    user="$(echo ${rest} | sed -nr 's,^([^:]+:).*,\1,p')"
    rest="$(echo ${rest/$user/})"
    user="$(echo ${user} | tr -d :)"

    pass="$(echo ${rest} | sed -nr 's,^(.*@).*,\1,p')"
    rest="$(echo ${rest/$pass/})"
    pass="$(echo ${pass} | tr -d @)"

    port="$(echo ${rest} | sed -nr 's,.*(:[0-9]+).*,\1,p')"
    rest="$(echo ${rest/$port/})"
    port="$(echo ${port} | tr -d :)"

    path="$(echo ${rest} | sed -nr 's,[^/:]*([/:].*),\1,p')"
    rest="$(echo ${rest/$path/})"
    path="$(echo ${path} | tr -d /)"

    host="$(echo ${rest/$path/})"

    echo "${schm}|${user}|${pass}|${host}|${port}|${path}"

    return 0
}

# init vars
IFS="|"
src_dsn=""
dst_dsn=""
list_file=""
verbose=0
inc_mode=0
cur_dir=`pwd`
tmp_dir="__syncdb_tmp"

src_schema=""
src_host=""
src_port=""
src_user=""
src_pass=""
src_db=""

dst_schema=""
dst_host=""
dst_port=""
dst_user=""
dst_pass=""
dst_db=""

# parse cli options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s|--source) src_dsn="$2"; shift;;
        -d|--destination) dst_dsn="$2"; shift;;
        -l|--list-file) list_file="$2"; shift;;
        -i|--include-mode) inc_mode=1;;
        -v|--verbose) verbose=1;;
        *) arg="$1"; shift;;
    esac;
    shift;
done

# options check
if [[ -z "$src_dsn" ]]; then
    echo "Source db dsn url is required. Please try again with option -s or --source." >&2
    exit 1
fi
if [[ -z "$dst_dsn" ]]; then
    echo "Destination db dsn url is required. Please try again with option -d or --destination." >&2
    exit 1
fi
if [[ -z "$list_file" ]]; then
    echo "List file is required. Please try again with option -l or --list-file." >&2
    exit 1
fi
# verbose
if [[ "$verbose" == "1" ]]
then
    echo -e "Init options:\n * working dir: $cur_dir\n * source db dsn url: $src_dsn\n * destination db dsn url: $dst_dsn\n * list file: $list_file\n"
fi

# parse source dsn url
read src_schema src_user src_pass src_host src_port src_db<<<$(dsn_url_parse ${src_dsn})
# ping server
ping_res=`mysqlshow -h ${src_host} -P ${src_port} -u ${src_user} -p${src_pass} | grep -o ${src_db} | head -n 1 | sed -e 's/^|//' -e 's/|$//' | xargs`
if [[ "$ping_res" != "${src_db}" ]]; then
    echo "Source db: failed ping. Credentials are wrong or server is unavailable now."
    exit 1
fi
# verbose
if [[ "$verbose" == "1" ]]
then
    echo -e "Source db:\n * schema: $src_schema\n * user: $src_user\n * pass: $src_pass\n * host: $src_host\n * port: $src_port\n * dbname: $src_db\n"
fi

# parse destination dsn url
read dst_schema dst_user dst_pass dst_host dst_port dst_db<<<$(dsn_url_parse ${dst_dsn})
# ping server
ping_res=`mysqlshow -h ${dst_host} -P ${dst_port} -u ${dst_user} -p${dst_pass} 2>/dev/null | grep -o ${dst_db} | head -n 1 | sed -e 's/^|//' -e 's/|$//' | xargs`
if [[ "$ping_res" != "${dst_db}" ]]; then
    echo "Destination db: failed ping. Credentials are wrong or server is unavailable now."
    exit 1
fi
# verbose
if [[ "$verbose" == "1" ]]
then
    echo -e "Destination db:\n * schema: $dst_schema\n * user: $dst_user\n * pass: $dst_pass\n * host: $dst_host\n * port: $dst_port\n * dbname: $dst_db\n"
fi

# create temporary workspace
mkdir -p ${tmp_dir}

# check list file exists
if [[ ! -f "$list_file" ]]; then
    echo "List file ${list_file} doesn't exists."
    exit 1
fi

# disable fk check
mysql -h ${dst_host} -P ${dst_port} -u ${dst_user} -p${dst_pass} ${src_db} -e "SET FOREIGN_KEY_CHECKS=0"

if [[ "$inc_mode" == "0" ]]
then
    echo "copy $src_host/$src_db to $dst_host/$dst_db:"
fi

# walk over list file
while IFS= read -r line
do
    # skip empty lines and comments
    if [[ "$line" == "" || "$line" =~ ^#.* ]]; then
        continue
    fi

    # check include expression
    re='^\.\s.*$'
    if [[ $line =~ $re ]]; then
        inc_dir=`dirname $list_file`
        inc_file=`echo $line | sed -e 's/\. *//'`
        if [[ "$inc_dir" ]]; then
          inc_file="$inc_dir/$inc_file"
        fi
        echo " * import $inc_file"
        cmd="sh $0 --source \"$src_dsn\" --destination \"$dst_dsn\" --list-file $inc_file --include-mode"
        eval "$cmd"
        continue
    fi

    IFS=: read -r table_raw script <<< "$line"
    # check if db is specified in the table name
    IFS=. read -r db table <<< "$table_raw"
    if [[ ${table} == "" ]]; then
        # set default db otherwise
        table=${db}
        db=${src_db}
    fi
    # check if whole table is marked to copy
    full_table=0
    if [[ ${script} == "*" ]]; then
        full_table=1
        script="select * from $db.$table"
    fi

    echo " * ${db}.${table}"
    # dump schema and data
    echo -e "   * dump ... \c"

    # prepare ddl data pool
    ddl_tmp="${tmp_dir}/__ddl_tmp"
    ddl="${tmp_dir}/ddl__${db}__${table}.sql"
    rm -f ${ddl_tmp}
    rm -f ${ddl}

    echo "DROP TABLE IF EXISTS ${db}.${table};" > ${ddl_tmp}
    echo -e `mysql -h ${src_host} -P ${src_port} -u ${src_user} -p${src_pass} ${db} -s -e "show create table ${db}.${table}" | awk -F"\t" '{print $2}' ` >> ${ddl_tmp}
    cat ${ddl_tmp} | sed "$!N;s/CREATE TABLE \`$table\`/CREATE TABLE \`$db\`.\`$table\`/;P;D" | sed '$!N;s/NOT NULL/NULL/;P;D' | sed '$!N;s/,\n\s*CONSTRAINT/\nCONSTRAINT/;P;D' | sed -r 's/CONSTRAINT `[^`]+` FOREIGN KEY \(`[^`]+`\) REFERENCES `[^`]+` \(`[^`]+`\)//' | sed -r 's/ON DELETE (RESTRICT|CASCADE|SET NULL|NO ACTION|SET DEFAULT)//' | sed -r 's/ON UPDATE (RESTRICT|CASCADE|SET NULL|NO ACTION|SET DEFAULT)//' | sed -r 's/AUTO_INCREMENT=[0-9]+//' | sed -r 's/AUTO_INCREMENT//' | sed -r 's/PRIMARY KEY \(`[^`]+`\),//' > ${ddl}

    # prepare dml data pool
    tuples_cnt=0

    dml_tmp="${tmp_dir}/__dml_tmp"
    dml="${tmp_dir}/dml__${db}__${table}.sql"
    rm -f ${dml_tmp}
    rm -f ${dml}

    if [[ "$full_table" == "1" ]]; then
        # dump the whole table - easy peasy with builtin mysqldump command
        mysqldump --single-transaction --no-tablespaces -t --skip-comments -h ${src_host} -P ${src_port} -u ${src_user} -p${src_pass} ${db} ${table} > ${dml}
        tuples_cnt=`mysql -h ${src_host} -P ${src_port} -u ${src_user} -p${src_pass} ${db} --batch --silent -e "select count(*) from $db.$table"`
    else
        # more stronger case - partial dump
        # need to get a select query result and format it as mysql's batched inserts

        # save raw batch data to dml temp file
        mysql -h ${src_host} -P ${src_port} -u ${src_user} -p${src_pass} ${db} --batch --silent -e "$script" | sed 's/"//g' | awk -F'\t' -v OFS="\",\"" '{ $1=$1 } 1' | sed -r 's/~/`/' | awk -F"~" '{print "(\""$1"\")"}' | sed '$!N;s/"NULL"/NULL/;P;D' > ${dml_tmp}
        # format raw batch data as mysql's insert query
        script1=$script
        re='(.*) [a-zA-Z0-9\.]+ as ([a-zA-Z0-9]+)(.*)'
        while [[ $script1 =~ $re ]]; do
            script1="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
        done
        fields=`echo ${script1} | grep -o -P '(?<=select).*(?=from)' | sed -r "s/if\([^=]+='',\s*'<nil>',[^\)]+\)\s*as//" | tr -d ' '`
        ins_prefix="insert into ${db}.${table}(${fields}) values"
        counter=0
        while IFS= read -r ins_line
        do
            if [[ $((counter%10000)) == 0 || "${counter}" == "0" ]]; then
                # make batch of 10k rows
                echo ";${ins_prefix}${ins_line}" >> ${dml}
            else
                echo ",${ins_line}" >> ${dml}
            fi
            counter=$((counter+1))
        done < "$dml_tmp"

        tuples_cnt=0
        if [ -f "$dml" ]; then
            tuples_cnt=`wc -l ${dml} | awk '{print $1}'`
        fi
    fi

    # dump finished
    echo "done"

    echo "     $tuples_cnt tuples ready to import"

    # import
    echo -e "   * import ... \c"

    # import schema
    mysql -h ${dst_host} -P ${dst_port} -u ${dst_user} -p${dst_pass} ${db} -f < ${ddl}
    # import data
    if [ -f "$dml" ]; then
        mysql -h ${dst_host} -P ${dst_port} -u ${dst_user} -p${dst_pass} ${db} -f < ${dml}
    fi

    # import finished

    echo "done"
done < "$list_file"

# enable back fk check
mysql -h ${dst_host} -P ${dst_port} -u ${dst_user} -p${dst_pass} ${src_db} -e "SET FOREIGN_KEY_CHECKS=1"

if [[ "$inc_mode" == "0" ]]
then
    echo "copying finished"

    # cleanup
    if [[ "$verbose" == "1" ]]; then
        echo -e "Cleanup ... \c"
    fi
    rm -rf ${tmp_dir}
    if [[ "$verbose" == "1" ]]; then
        echo -e "done"
    fi
fi
