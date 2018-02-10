# Portable Gentoo DistCC
Just a bunch of shell commands to run the most recent build tools available in Gentoo in other GNU/Linux distributions such as Ubuntu. It downloads the latest stage3 tarball, performs some configuration, chroots into it and runs DistCC. 

**WARNING**: Not thoroughly tested, do not use it on your main machine.

## Getting started 

Clone the repository and run

    ./init.sh

## Configure DistCC
    cd /mnt/gentoo
    sudo chroot . /bin/bash
    nano /etc/conf.d/distcc 
    rc-service distccd restart
