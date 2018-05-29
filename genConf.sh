#!/bin/sh

if [ ! -d /var/db ]; then

	mkdir -p /var/db

fi

echo "cp config ...."
cp ./conf/etc/* /etc/

cp ./conf/var/db/turndb /var/db

if [ ! -f /lib/systemd/system/avchat-turnserver.service ]; then

	echo "copy avchat-turnserver.service ...."
	cp ./conf/avchat-turnserver.service /lib/systemd/system/

else
	echo "avchat-turnserver.service is existed"

fi

if [ ! -f /usr/bin/avchat-turnserver-server ]; then

	echo "copy avchat-turnserver-server ...."
	cp ./conf/avchat-turnserver-server /usr/bin/
else
	echo "avchat-turnserver-server is existed"

fi


echo "success"


