echo "Importing pool suedp with -f"
zpool import -f suedp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
echo "Exporting pool suedp"
zpool export suedp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo "done, disabling service"
svcadm disable force_import_export_suedpool
