# This script is supposed to be run automatically 
# by the init script, do not run manually!

# Emering iputils is required to use the ping utility because the host filesystem does 
# possibly not allow binaries that do not make use of Linux capabilities(7)
echo "nameserver 8.8.8.8" > /etc/resolv.conf;
emerge-webrsync
emerge iputils distcc

# TODO: modify distcc configuration

# Enable OpenRC in chrooted environment
mkdir -p /lib64/rc/init.d
ln -s /lib64/rc/init.d /run/openrc
touch /run/openrc/softlevel
emerge --oneshot sys-apps/openrc

# Customize OpenRC configuration to work when being started at boot
cat <<EOT >> /etc/rc.conf
rc_sys="prefix"
rc_controller_cgroups="NO"
rc_depend_strict="NO"
rc_need="!net !dev !udev-mount !sysfs !checkfs !fsck !netmount !logger !clock !modules"
EOT

# Start the DistCC daemon
rc-service distccd start
