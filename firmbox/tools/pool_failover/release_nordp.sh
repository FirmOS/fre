ipadm delete-addr vmnfs0/v4n0
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
ipadm delete-addr vmnfs1/v4n1
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
zpool export nordp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi