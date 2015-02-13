zpool destroy -f testpool
zfs destroy -r zones/testfiles
zfs create zones/testfiles
dd if=/dev/zero of=/zones/testfiles/file1 bs=1M count=100
dd if=/dev/zero of=/zones/testfiles/file2 bs=1M count=100
dd if=/dev/zero of=/zones/testfiles/file3 bs=1M count=100
dd if=/dev/zero of=/zones/testfiles/file4 bs=1M count=100
zpool create testpool raidz1 /zones/testfiles/file1 /zones/testfiles/file2 /zones/testfiles/file3 /zones/testfiles/file4


