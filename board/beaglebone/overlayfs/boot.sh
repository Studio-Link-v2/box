#!/bin/sh -ex

led_on() {
    echo "Empty"
}

led_off() {
    echo "Empty"
}

refresh_datetime() {
    export TZ=CET-1CEST,M3.5.0/2,M10.5.0/3 # Timezone = Europe/Berlin
    ntpdate 0.de.pool.ntp.org
}

refresh_ip() {
    hostname=$(cat /root/.studio-link/uuid | awk -F- '{ print $1 }')
    private_ip=$(ip -f inet address show eth0 | \
        grep inet | awk '{ print $2 }' | awk -F/ '{ print $1 }')

    curl --data "hostname=$hostname&private_ip=$private_ip" \
        https://vpn.studio-link.de/update.php

    return 0
}

update() {
    version=$(curl https://vpn.studio-link.de/boxversion.html)
    version_r=$(cat /slversion)

    if [ "$version" == "$version_r" ]; then
        echo "No update needed"
        return 0
    fi

    mkdir -p /boot
    mount /dev/mmcblk0p1 /boot

    part="/dev/mmcblk0p2"
    grep $part /boot/uEnv.txt && part='/dev/mmcblk0p3'

    wget -O /data/image.tar.gz https://server.visr.de/slbox/$version.tar.gz
    gunzip /data/image.tar.gz

    mkdir -p /update
    mount $part /update

    rm -Rf /update/*
    tar -xf /data/image.tar -C /update
    sync
    rm -f /data/image.tar
    mkdir -p /update/root/.studio-link
    cp -a /root/.studio-link/uuid /update/root/.studio-link/

    /update/hook.sh
    rm -f /update/hook.sh

cat > /boot/uEnv.txt_test <<EOF
bootpart=1:1
bootdir=
bootargs=console=ttyO0,115200n8 root=$part rw rootfstype=ext4 rootwait
uenvcmd=run loadimage;run loadfdt;printenv bootargs;bootz \${loadaddr} - \${fdtaddr};
EOF

    umount /boot

    return 0 
}


# Main {
led_on
refresh_datetime
refresh_ip
update
led_off
#}
