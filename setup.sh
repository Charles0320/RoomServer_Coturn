#!/bin/bash

SCRIPT_DIR=$(realpath $(dirname $0))
echo "script dir:${SCRIPT_DIR}"

WORK_PATH="${HOME}/CharlesWork"

ZOO_PATH="${WORK_PATH}/zookeeper"

SYSTEM_DIR='/lib/systemd/system'

CONFIG_NAME='avchat-turnserver.service'

SYSTEM_CONFIG="${SYSTEM_DIR}/${CONFIG_NAME}"



if [ -f "${SCRIPT_DIR}/src/app/relay/mainrelay.h" ]
then
	COTURN_PATH="${SCRIPT_DIR}"
else
	COTURN_PATH="${WORK_PATH}/RoomServer_Coturn"
fi

DISTRIBUTOR_ID=$(lsb_release -is)
echo "DISTRIBUTOR_ID = ${DISTRIBUTOR_ID}"

mkdir -pv "${WORK_PATH}" && cd "${WORK_PATH}" || exit 1

function jwaoo_install_depends()
{
	case "${DISTRIBUTOR_ID}" in
		Ubuntu)
			apt-get -y install git g++ make libtool automake autoconf pkg-config unzip libcppunit-dev libssl-dev sqlite3 libsqlite3-dev libevent-dev libhiredis-dev libpq-dev mysql-client|| return 1
			;;

		CentOS)
			yum -y install gcc-c++ libtool libcppunit-dev openssl-devel sqlite libsqlite3-dev libevent libevent-devel  hiredis hiredis-devel || return 1
			;;

		*)
			echo "Invalid Distributor ID!"
			return 1
	esac
}




function jwaoo_git_clone()
{
	echo "git clone $@"
	[ -d "$2" ] || git clone "$1" "$2" || return 1
	cd "$2" || return 1
	[ -z "$3" ] || git checkout "$3" || return 1
}

function jwaoo_install_zookeeper()
{
	echo "Build: ${LIBMONGOC_PATH}"
	jwaoo_git_clone "http://180.169.167.166:6380/git/zookeeper.git" "${ZOO_PATH}" "v3.4.12" || return 1

	cd ./src/c || return 1
	./configure --prefix=/usr || return 1
	make -j && make install || return 1
}

function jwaoo_coturn_systemd()
{
	echo '[Unit]' > $SYSTEM_CONFIG
	echo 'Description=Avhat Turnserver' >> $SYSTEM_CONFIG
	echo 'After=network.target' >> $SYSTEM_CONFIG
	echo '' >> $SYSTEM_CONFIG
	echo '[Service]' >> $SYSTEM_CONFIG
	echo 'Type=simple' >> $SYSTEM_CONFIG
	echo 'Restart=always' >> $SYSTEM_CONFIG
	echo 'PIDFile=/run/avchat/avchat_turnserver.pid' >> $SYSTEM_CONFIG
	echo 'ExecStart=/usr/bin/turnserver' >> $SYSTEM_CONFIG
	echo '' >> $SYSTEM_CONFIG
	echo '[Install]' >> $SYSTEM_CONFIG
	echo 'WantedBy=multi-user.target' >> $SYSTEM_CONFIG

	systemctl daemon-reload

	systemctl enable $CONFIG_NAME
	

}

function jwaoo_copy_Config()
{

	if [ ! -d /var/db ]; then

		mkdir -p /var/db

	fi

	echo "cp config ...."
	cp ${COTURN_PATH}/conf/etc/* /etc/

	cp ${COTURN_PATH}/conf/var/db/turndb /var/db

}


function jwaoo_install_coturn()
{
	echo "Build: ${COTURN_PATH}"
	jwaoo_git_clone "http://180.169.167.166:6380/git/RoomServer_Coturn.git" "${COTURN_PATH}"  "v1.0.0" || return 1

	jwaoo_install_compile || return 1

	jwaoo_coturn_systemd || return 1

	jwaoo_copy_Config || return 1



}

function jwaoo_install_compile()
{

	cd ${COTURN_PATH}
	./configure --prefix=/usr || return 1
	make -j && make install || return 1

}





case "$1" in
	depends)
		jwaoo_install_depends
		;;

	zookeeper)
		jwaoo_install_zookeeper
		;;

	coturn)
		jwaoo_install_coturn
		;;
	compile)
		jwaoo_install_compile
		;;

	*)
		jwaoo_install_depends && jwaoo_install_zookeeper && jwaoo_install_coturn 
		;;
esac




























