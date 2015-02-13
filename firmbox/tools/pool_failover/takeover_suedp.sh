zpool import suedp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
ipadm create-addr -T static -a 10.54.250.110/25 vmnfs0/v4s0
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
ipadm create-addr -T static -a 10.54.250.210/25 vmnfs1/v4s1
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi