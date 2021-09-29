#!/usr/bin/env bash

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
