#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

echo "*******************************************************"
whoami
echo "*******************************************************"

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.1.10
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

sudo mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
#	sudo git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

#if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
#    cd linux-stable
#    sudo chmod -R 0777 ${OUTDIR}/linux-stable/
#    echo "Checking out version ${KERNEL_VERSION}"   

#    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
#    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
#    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
#    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
#    sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
#    # TODO: Add your kernel build steps here
#fi

#echo "Adding the Image in outdir"
#sudo cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image

su sachin

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
    echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
sudo mkdir rootfs
cd rootfs
sudo mkdir bin dev etc home lib proc sbin sys tmp usr var
sudo mkdir usr/bin usr/lib usr/sbin
sudo mkdir -p var/log

sudo chown -R root:root *

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    sudo git clone git://busybox.net/busybox.git
    sudo chmod -R 0777 busybox
    sudo chown -R root:root *
    cd busybox
    sudo git checkout -f ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make distclean
    make defconfig
else
    sudo chown -R root:root *
    sudo chmod -R 777 busybox
    cd busybox
fi

# TODO: Make and install busybox
#make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX="${OUTDIR}/rootfs" 
sudo chmod u+s ${OUTDIR}/busybox
sudo make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX="${OUTDIR}/rootfs" install


cd ../rootfs

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"


echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=`${CROSS_COMPILE}gcc --print-sysroot`
sudo cp -a "${SYSROOT}"/lib/* lib/
sudo cp -a "${SYSROOT}"/lib64 .

# TODO: Make device nodes
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 666 dev/console c 5 1

# TODO: Clean and build the writer utility
cd "${FINDER_APP_DIR}"
sudo make clean
sudo make HOSTCC=gcc-9 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
# TODO: Copy the finder related scripts and executables to the /home directory
sudo cp -a writer finder.sh finder-test.sh autorun-qemu.sh "${OUTDIR}/rootfs/home"
sudo mkdir "${OUTDIR}/rootfs/home/conf"
sudo cp -a conf/username.txt "${OUTDIR}/rootfs/home/conf"

cd "${OUTDIR}/rootfs"

# on the target rootfs

# TODO: Chown the root directory
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz

echo "Start creating initramfs.cpio.gz"
cd "$OUTDIR/rootfs"
sudo chmod -R 0777 $OUTDIR 
find . | cpio -o --format=newc > ../initramfs.cpio
sudo gzip -c ../initramfs.cpio > ../initramfs.cpio.gz

su root
