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
raw=$(go list -u -mod=mod -f '{{if (and (not (or .Main .Indirect)) .Update)}}{{.Path}}|{{.Version}} => {{.Update.Version}}{{end}}' -m all)
echo "done"

cmdDlg="dialog --keep-tite --checklist \"Modules to update\" 0 0 0"

while IFS= read -r line
do
    mod="${line%%|*}"
    ver="${line#*|}"
    cmdDlg="$cmdDlg \"$mod\" \"$ver\" off"
done <<< "$raw"

cmdDlg="$cmdDlg --output-fd 1"

choices=$(eval "$cmdDlg")
echo "$choices"

if [ -z "$choices" ]; then
    echo "No modules to update"
    exit 0
fi

echo "Updating ..."
