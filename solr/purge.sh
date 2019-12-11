#!/usr/bin/env bash

echo -e "stopping the service ... \c"
systemctl stop solr
echo "done"

echo -e "remove system user and group ... \c"
userdel -rf solr
groupdel -f solr
echo "done"

echo -e "remove solr distribution ... \c"
rm -rf /var/solr*
echo "done"

echo -e "remove scripts ... \c"
rm -f /etc/init.d/solr
rm -f /etc/default/solr.in.sh
echo "done"
