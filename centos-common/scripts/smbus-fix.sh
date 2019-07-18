echo "Virtual machines generally can't access the host's SMBus controller."
echo 'applying fix per https://access.redhat.com/solutions/42741'
echo 'blacklist i2c-piix4' >> /etc/modprobe.d/blacklist.conf
dracut -f /boot/initramfs-`uname -r`.img `uname -r`

echo "rebooting..."
reboot
echo "Sleeping for 60 seconds..."
sleep 60
