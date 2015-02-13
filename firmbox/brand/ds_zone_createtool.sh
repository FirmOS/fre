#!/bin/sh
# $1= DOMAINUID
# $2= ZONEUID
# $3= FBZname (fbz03)
zfs create rpool/globalshared
zfs set mountpoint=legacy rpool/globalshared
zfs create rpool/domains
zfs create rpool/domains/$1
zfs create rpool/domains/$1/shared
zfs set mountpoint=legacy rpool/domains/$1/shared
zfs create rpool/domains/$1/$2
zfs create rpool/domains/$1/$2/vmdisk
zfs create rpool/domains/$1/$2/zonedata
zfs clone rpool/template/$3/etc@final rpool/domains/$1/$2/zonedata/etc
zfs clone rpool/template/$3/var@final rpool/domains/$1/$2/zonedata/var
zfs set mountpoint=legacy rpool/domains/$1/$2/zonedata/etc
zfs set mountpoint=legacy rpool/domains/$1/$2/zonedata/var
zfs set mountpoint=legacy rpool/domains/$1/$2/zonedata
zoneadm -z $2 install -t rpool/template/$3
dladm create-vnic -l e1000g0 net0

