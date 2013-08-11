#!/bin/bash

set -o errexit

SRC_PACK='twolame-0.3.13.tar.gz'

SRC_ROOT=`pwd`/twolame-0.3.13
BUILD_PATH=`pwd`/build/twolame
LIB_LINK_PATH=`pwd`/build
HAEDER_LINK_PATH="$LIB_LINK_PATH/include"

LIBS=('libtwolame.a')
ARCHS=('armv7' 'armv7s' 'i386')

DEVELOPER_ROOT='/Applications/Xcode.app/Contents/Developer'
IOS_VERSION='6.1'
#CC="$DEVELOPER_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

CPU_CORE_COUNT=`sysctl -n machdep.cpu.core_count` #Check cpu core number
MAKE_JOBS=$((CPU_CORE_COUNT+1))

function build_with_args() {
	local arch=$1
	local platform=$2
	local host=$3
	local build=$4
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

	export CC="$ios_dev_root/usr/bin/llvm-gcc"
	export CFLAGS="-arch $arch -isysroot $sys_root -I$sys_root/usr/include"
	export CPPFLAGS=$CFLAGS
	export AS="$AS /usr/local/bin/gas-preprocessor.pl $CC"

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
	--with-sysroot="$sys_root" \
	--disable-shared

	echo "Building for $arch ..."

	make -j $MAKE_JOBS
	make install

	echo "Build for $arch completed!"

	cd -
}

function build_armv7() {
	build_with_args \
	'armv7' \
	'OS' \
	'arm-apple-darwin' \
	'arm-apple-darwin10'
}

function build_armv7s() {
	build_with_args \
	'armv7s' \
	'OS' \
	'arm-apple-darwin' \
	'arm-apple-darwin10'
}

function build_i386() {
	local platform='Simulator'
	build_with_args \
	'i386' \
	'Simulator' \
	'i686-apple-darwin' \
	'i686-apple-darwin11'
}

function create_universal_libs() {

	cd $BUILD_PATH
	
	local universal_path="$BUILD_PATH/universal"
	if [ ! -d $universal_path ]; then
		mkdir $universal_path
	fi

	for lib in ${LIBS[*]}
	do
		local args=''
		for arch in ${ARCHS[*]}
		do
			args="$args $arch/lib/$lib"
		done
		local create_cmd="lipo -create $args -output $universal_path/$lib"
		echo $create_cmd
		$create_cmd
		ln -sFfv "$universal_path/$lib" "$LIB_LINK_PATH"
		args=''
	done
	
	if [ ! -d "$HAEDER_LINK_PATH" ];then
		mkdir -p "$HAEDER_LINK_PATH"
	fi
	
	ln -sFfv "$BUILD_PATH/${ARCHS[0]}/include"/* "$HAEDER_LINK_PATH/"
	
	cd -
}

function build_all() {
	if [ -d $BUILD_PATH ]; then
		echo "Cleanning $BUILD_PATH..."
		rm -rf $BUILD_PATH
	fi
	
	for value in ${ARCHS[*]}
	do 
		build_$value #编译传入的平台库版本
	done
	
	create_universal_libs
}

build_all

echo '>>>>>>>>>>>>>>>>>All completed!<<<<<<<<<<<<<<'
exit 0