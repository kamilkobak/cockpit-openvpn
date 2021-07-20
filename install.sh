#!/bin/bash
NAME="openvpn"
LNAME="cockpit-$NAME"
USRDIR="/usr"
OPTDIR="/opt"
CKPTDIR="share/cockpit"
USRLOC="$USRDIR/$CKPTDIR/$NAME"
OPTLOC="$OPTDIR/$NAME"
EASY_RSA_VERSION="3.0.8"
USR_DIR="/usr/share"
EASY_RSA_DIR=${USR_DIR}"/easy-rsa"
EASY_RSA_CMD=${EASY_RSA_DIR}"/easyrsa"
EASY_RSA_TGZ_FILE="EasyRSA-"${EASY_RSA_VERSION}".tgz"
EASY_RSA_URL="https://github.com/OpenVPN/easy-rsa/releases/download/v"${EASY_RSA_VERSION}"/"${EASY_RSA_TGZ_FILE}



if [ "$EUID" -ne 0 ]
then
	echo "Please execute as root ('sudo install.sh' or 'sudo make install')"
	exit
fi

if [ "$1" == "-u" ] || [ "$1" == "-U" ]
then
	echo "$LNAME uninstall script"

    echo "Removing files"
	if [ -d "$USRLOC" ]; then
        rm -rf "$USRLOC"
    fi
    if [ -d "$OPTLOC" ]; then
        rm -rf "$OPTLOC"
    fi

elif [ "$1" == "-h" ] || [ "$1" == "-H" ]
then
	echo "Usage:"
	echo "  <no argument>: install $NAME"
	echo "  -u/ -U       : uninstall $NAME"
	echo "  -h/ -H       : this help file"
else
    echo "$LNAME install script"

    #OpenVPN instalation
    apt install openvpn -y

    #EasyRSA Instalation
    if [ ! -d "${EASY_RSA_DIR}" ]; then
     echo Downloading ${EASY_RSA_URL} ...
     wget ${EASY_RSA_URL}

     echo Extracting ${EASY_RSA_TGZ_FILE} to ${EASY_RSA_DIR}
     tar -zxf ${EASY_RSA_TGZ_FILE}

     mv "EasyRSA-"${EASY_RSA_VERSION} ${EASY_RSA_DIR}
     rm ${EASY_RSA_TGZ_FILE}
    else
     echo ${EASY_RSA_DIR} already exists
    fi

    #Plugin instalation
    if [ ! -d "$USRLOC" ]; then
        mkdir "$USRLOC"
    fi
    cp -r "$NAME/." "$USRLOC/"

    if [ ! -d "$OPTLOC" ]; then
        mkdir "$OPTLOC"
    fi
    cp -r "./$OPTDIR/." "$OPTDIR/"

    #Plugin activation
    echo setup certificates ...
    $OPTLOC/openvpn-cli.py setup_cert

    echo
    echo "Plugin Installation complete"
    echo



fi

