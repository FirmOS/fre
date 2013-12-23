ipadm delete-addr vmnfs0/v4s0
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
ipadm delete-addr vmnfs1/v4s1
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
zpool export suedp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi