# Script for bootstrapping Gentoo from other GNU/Linux distributions with the distcc package
#!/bin/bash

# Filter for less cluttered wget output
progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

FILEPATH=$(wget -q -O - http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt | awk 'NR==3{print $1}');
ROOT="http://distfiles.gentoo.org/releases/amd64/autobuilds/";
FILENAME=$(echo $FILEPATH | cut -d"/" -f2);
DIGESTS="$FILENAME.DIGESTS.asc";

# Create directories and move the second stage script to the chroot directory, which will be executed directly after chrooting
echo "Creating /mnt/gentoo";
sudo mkdir -p /mnt/gentoo;
sudo cp ./chroot.sh /mnt/gentoo/;
cd /mnt/gentoo;


# Download tarball and signature
echo "Downloading Gentoo stage3 tarball";
sudo wget --progress=bar:force $ROOT$FILEPATH # 2>&1 | progressfilt;
echo "Downloading signature";
sudo wget --progress=bar:force $ROOT$FILEPATH.DIGESTS.asc # 2>&1 | progressfilt;
gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910;

# Parsing the output of sha512sum manually because it contains errors due 
# to Whirlpool hashes that are not supported by sha512sum
if [ "$(sha512sum -c $DIGESTS --ignore-missing | awk 'NR==1{print $2; exit}')" == "OK" ]
then
	echo "Signature verified!";
else
	echo "Signature mismatch, quitting...";
	exit;
fi

# Move extracted tarball to mount 
echo "Decompressing Gentoo stage3 tarball";
sudo tar xf $FILENAME

# Mount filesystems
sudo mount --types proc /proc /mnt/gentoo/proc
sudo mount --rbind /sys /mnt/gentoo/sys
sudo mount --make-rslave /mnt/gentoo/sys
sudo mount --rbind /dev /mnt/gentoo/dev
sudo mount --make-rslave /mnt/gentoo/dev

# Move second stage script into root and chroot into Gentoo
sudo chmod +x /mnt/gentoo/chroot.sh
sudo chroot . ./chroot.sh

