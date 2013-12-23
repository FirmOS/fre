echo "Importing pool nordp with -f"
zpool import -f nordp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi
echo "Exporting pool nordp"
zpool export nordp
rc=$?
if [[ $rc != 0 ]] ; then
    exit $rc
fi

echo "done, disabling service"
svcadm disable force_import_export_nordpool
