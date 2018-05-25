#!/bin/sh

if [ ! -d /var/db ]; then

	mkdir -p /var/db

fi

echo "cp config ...."
cp ./conf/etc/* /etc/

cp ./conf/var/db/turndb /var/db


echo "success"


