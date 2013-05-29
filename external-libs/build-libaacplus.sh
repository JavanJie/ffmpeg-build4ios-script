#!/bin/bash

SRC_PACK='libaacplus-2.0.2.tar.gz'

SRC_ROOT=`pwd`/libaacplus-2.0.2
BUILD_PATH=`pwd`/build

DEVELOPER_ROOT='/Applications/Xcode.app/Contents/Developer'
IOS_VERSION='6.1'
#CC="$DEVELOPER_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

CPU_CORE_COUNT=`sysctl -n machdep.cpu.core_count` #Check cpu core number
MAKE_JOBS=$CPU_CORE_COUNT+1

function build_with_args() {
	local arch=$1
	local platform=$2
    local host=$3
    local cc=$4
    local build=$5
    local cpp=$6
    local ios_dev_root="$DEVELOPER_ROOT/Platforms/iPhone$platform.platform/Developer"
    local sys_root="$ios_dev_root/SDKs/iPhone$platform$IOS_VERSION.sdk"

    if [ -d $SRC_ROOT ]; then
        echo "Cleaning $SRC_ROOT ..."
        rm -rf $SRC_ROOT    
        echo "Clean $SRC_ROOT completed!"
    fi
    
    echo "Decompressing $SRC_PACK ..."
    tar -xzf $SRC_PACK
    echo "Decompress $SRC_PACK completed!"

	cd $SRC_ROOT
    
    export PATH="$ios_dev_root/usr/bin:$DEVELOPER_ROOT/usr/bin:$PATH"
    export CC=$cc
    export CFLAGS="-I$sys_root/usr/include" 
    export LDFLAGS="--sysroot=$sys_root -L$sys_root/usr/lib/ -L$sys_root/usr/lib/system"
    export CPPFLAGS=$CFLAGS
    export CPP=$cpp
    export TARGET=$build

	local wating_time=10s 
	# 为避免脚本执行时出现如下错误，这里设定延迟时间：
	# checking whether build environment is sane... configure: error: newly created file is older than distributed files!
	# Check your system clock
	echo "Waiting $wating_time ..."
	sleep $wating_time
	
	./configure \
	--prefix="$BUILD_PATH/$arch" \
	--host=$host \
    --build=$build \
	--with-sysroot=$sys_root \
    --enable-shared \
    --enable-static 

	echo "Building for $arch ..."

#	make -j$MAKE_JOBS
	make install
	make clean

	echo "Build for $arch completed!"

	cd -
}

function build_armv7() {
    local platform='OS'
    local bin_path="$DEVELOPER_ROOT/Platforms/iPhone$platform.platform/Developer/usr/bin"
	build_with_args \
        'armv7' \
        "$platform" \
        'arm' \
        "$bin_path/arm-apple-darwin10-llvm-gcc-4.2" \
        'arm-apple-darwin10' \
        "$bin_path/arm-apple-darwin10-llvm-g++-4.2"
}

function build_armv7s() {
    local platform='OS'
    local bin_path="$DEVELOPER_ROOT/Platforms/iPhone$platform.platform/Developer/usr/bin"
	build_with_args \
        'armv7s' \
        "$platform" \
        'arm' \
        "$bin_path/arm-apple-darwin10-llvm-gcc-4.2" \
        'arm-apple-darwin10' \
        "$bin_path/arm-apple-darwin10-llvm-g++-4.2"
}

function build_i386() {
    local platform='Simulator'
    local bin_path="$DEVELOPER_ROOT/Platforms/iPhone$platform.platform/Developer/usr/bin"
	build_with_args \
        'i386' \
        "$platform" \
        'i386' \
        "$bin_path/i686-apple-darwin11-llvm-gcc-4.2" \
        'i686-apple-darwin11' \
        "$bin_path/i686-apple-darwin11-llvm-g++-4.2"


}

if [ -d $BUILD_PATH ]; then
    echo "Cleaning $BUILD_PATH..."
    rm -rf $BUILD_PATH
fi

build_armv7
#build_armv7s
#build_i386

echo '>>>>>>>>>>>>>>>>>All completed!<<<<<<<<<<<<<<'

