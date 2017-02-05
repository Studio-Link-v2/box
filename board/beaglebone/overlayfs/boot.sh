#!/bin/sh -ex

led_on() {
    gpio61="/sys/class/gpio/gpio61"
    echo 61 > /sys/class/gpio/export
    echo out > $gpio61/direction
    echo 1 > $gpio61/value
}

led_off() {
    gpio61="/sys/class/gpio/gpio61"
    echo 0 > $gpio61/value
    echo 61 > /sys/class/gpio/unexport
}

blink() {
    led_off
    sleep 2
    led_on
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

update_password() {
    password=$(cat /root/.studio-link/uuid | awk -F- '{ print $1 }')
    echo "root:$password" | chpasswd
}

mount_data() {
    mkdir -p /data
    mount /dev/mmcblk0p4 /data
    rm -f /root/studio-link
    ln -s /data /root/studio-link
}

update() {
    version=$(curl https://vpn.studio-link.de/boxversion.html)
    version_r=$(cat /slversion)

    if [ "$version" == "$version_r" ]; then
        echo "No update needed"
        return 0
    fi

    blink # 1. Blink - Start Update

    mkdir -p /boot
    mount /dev/mmcblk0p1 /boot

    part="/dev/mmcblk0p2"
    grep $part /boot/uEnv.txt && part='/dev/mmcblk0p3'

    rm -f /data/image.tar.gz
    rm -f /data/image.tar

    curl https://server.visr.de/slbox/$version.tar.gz > /data/image.tar.gz
    gunzip /data/image.tar.gz

    mkdir -p /update
    mount $part /update

    blink # 2. Blink - Extract Image

    rm -Rf /update/*
    tar -xf /data/image.tar -C /update

    rm -f /data/image.tar
    mkdir -p /update/root/.studio-link
    cp -a /root/.studio-link/uuid /update/root/.studio-link/
    cp -a /etc/ssh/* /update/etc/ssh/

    blink # 3. Blink - Execute Hook

    /update/hook.sh
    rm -f /update/hook.sh

    sync

    blink # 4. Blink - Update boot

cat > /boot/uEnv.txt <<EOF
bootpart=1:1
bootdir=
bootargs=console=ttyO0,115200n8 root=$part rw rootfstype=ext4 rootwait
uenvcmd=run loadimage;run loadfdt;printenv bootargs;bootz \${loadaddr} - \${fdtaddr};
EOF

    umount /boot

    reboot
}


# Main {
led_on
refresh_datetime
refresh_ip
update_password
mount_data
update
led_off
#}
