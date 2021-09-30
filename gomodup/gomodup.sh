#!/usr/bin/env bash

force=0
tidy=0
vendor=0
ftv=$(awk '{a=0}/-[f|t|v]+/{a=1}a' <<<"$1")
mods=()

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) force=1;;
        -t|--tidy) tidy=1;;
        -v|--vendor) vendor=1;;
        "$ftv")
            if [[ "$1" =~ [f] ]]; then force=1; fi
            if [[ "$1" =~ [t] ]]; then tidy=1; fi
            if [[ "$1" =~ [v] ]]; then vendor=1; fi
            ;;
        *) shift;;
    esac;
    shift;
done

echo -n "Checking modules versions ... "
raw=$(go list -u -mod=mod -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}}|{{.Version}} => {{.Update.Version}}{{end}}' -m all 2>&1)
exc=$?
if [ $exc == 0 ]; then
    echo "done"
else
    echo -e "failed with error:\n$raw"
    exit 0
fi

cmdDlg="dialog --keep-tite --checklist \"Modules to update\" 0 0 0"

while IFS= read -r line
do
    mod="${line%%|*}"
    ver="${line#*|}"
    cmdDlg="$cmdDlg \"$mod\" \"$ver\" off"
    mods+=("$mod")
done <<< "$raw"

cmdDlg="$cmdDlg --output-fd 1"

if [ $force == 0 ]; then
    choices=$(eval "$cmdDlg")
    if [ -z "$choices" ]; then
        echo "No modules to update"
        exit 0
    fi
    IFS=' ' read -ra mods <<< "$choices"
    echo "Updating chosen modules:"
else
    echo "Updating modules in force mode:"
fi

for mod in "${mods[@]}"
do
	eval "go get $mod"
done

if [ $tidy == 1 ]; then
    echo "Apply \"go mod tidy\" command"
    go mod tidy
fi

if [ $vendor == 1 ]; then
    echo "Apply \"go mod vendor\" command"
    go mod vendor
fi

echo "done"
