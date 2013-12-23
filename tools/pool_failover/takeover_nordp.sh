zpool import nordp

rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

ipadm create-addr -T static -a 10.54.250.100/25 vmnfs0/v4n0
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

ipadm create-addr -T static -a 10.54.250.200/25 vmnfs1/v4n1
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

