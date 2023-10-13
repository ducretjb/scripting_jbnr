#!/bin/bash
source ../fwrapper.sh
fcolor

[ "$EUID" -ne 0 ] && { echo -e $LIGHTGREEN"run as #"$NC; exit 1; }

fpkg_install bind9
fpkg_install dnsutils

touch /etc/bind/db.root
dig NS . @a.root-servers.net > /etc/bind/db.root

IP=$(awk -F'\t' '$1 == "ip" {print $2}' dnsinstall.conf)
HOST=$(awk -F'\t' '$1 == "host" {print $2}' dnsinstall.conf)

ffile_bak /etc/hostname
! cat /etc/hostname | grep -q $HOST && echo $HOST >> /etc/hostname

ffile_bak /etc/hosts
! cat /etc/hosts | grep -q $HOST && echo "$IP	$HOST" >> /etc/hosts

ffile_bak "/etc/bind/named.conf.options"
cat named.conf.options.1 > /etc/bind/named.conf.options
ffile_bak "/etc/bind/named.conf.local"
cat named.conf.local.1 > /etc/bind/named.conf.local

cp -v db.devops.com.1 /etc/bind/db.devops.com
cp -v db.1.168.192.in-addr.arpa.1 /etc/bind/db.1.168.192.in-addr.arpa

named-checkconf -z
service bind9 restart
dig debian.devops.com
rndc reload
