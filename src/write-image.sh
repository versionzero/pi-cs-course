#!/bin/bash -x

N=${1:-10}

DISK=/dev/disk${N}
RDISK=/dev/rdisk${N}

if [ ! -e "${DISK}"  ]; then
    echo "ERROR: ${DISK} does not exist."
    exit 1
fi

IMAGE=${2:-2013-07-26-wheezy-raspbian.img}

if [ ! -e "${IMAGE}" ]; then
    echo "ERROR: ${IMAGE} does not exist."
    exit 1
fi

if [ $(id -u) != "0" ]; then
    echo "Must be root."
    exit 1
fi

diskutil unmountDisk ${DISK}
sudo dd if=${IMAGE} of=${RDISK} bs=1m
diskutil eject ${DISK}
