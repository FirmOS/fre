ifconfig net2 unplumb
if [ $1 = "0.14" ]; then
 echo "starting version 0.14"
 qemu="/smartdc/bin/qemu-system-x86_64"
 $qemu -vnc 0.0.0.0:1 -boot cd -enable-kvm -smp 4 -m 1024 \
 -cpu qemu64 \
 -drive file=/dev/zvol/rdsk/zones/qemu-ds/win_vol,if=virtio,index=0 \
 -usb -usbdevice tablet -k de \
 -device virtio-net-pci,mac=32:9e:f3:74:2c:ee,tx=timer,x-txtimer=200000,x-txburst=128,vlan=0 \
 -net vnic,name=net2,vlan=0,ifname=net2 
# -drive file=/zones/qemu-ds/isos/win7.iso,media=cdrom,if=ide,index=2 \
# -drive file=/zones/qemu-ds/isos/virtio.iso,media=cdrom,if=ide,index=3
 #-no-acpi
else
 echo "starting version 1.1.2"
 qemu="/opt/local/bin/qemu-system-x86_64"
 $qemu -vnc 0.0.0.0:1 -boot cd -enable-kvm -smp 4 -m 1024 \
 -cpu qemu64 \
 -drive file=/dev/zvol/rdsk/zones/qemu-ds/win_vol,if=virtio,index=0 \
 -usb -usbdevice tablet -k de \
 -qmp unix:/var/run/qmp-sockVM1,server,nowait \
 -daemonize \
 -pidfile /var/run/qemuVM1.pid \
 -device virtio-net-pci,mac=32:9e:f3:74:2c:ee,tx=timer,x-txtimer=200000,x-txburst=128,vlan=0 \
 -net vnic,name=net2,vlan=0,ifname=net2 
 #-drive file=/zones/qemu-ds/isos/win7.iso,media=cdrom,if=ide,index=2 \
# -drive file=/zones/qemu-ds/isos/virtio.iso,media=cdrom,if=ide,index=3
 #-no-acpi 
fi
 