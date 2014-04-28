yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
package-cleanup --oldkernels --count 1
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso
rm -rf /tmp/rubygems-*

