#!/bin/bash

set -o errexit

FFMPEG_SRC_PACK='ffmpeg-2.0.tar.gz'

FFMPEG_ROOT=`pwd`/ffmpeg
BUILD_PATH=`pwd`/build
EXTERNAL_LIBRARY_SEARCH_PATH=`pwd`/external-libs/build
EXTERNAL_HEADER_SEARCH_PATH="$EXTERNAL_LIBRARY_SEARCH_PATH/include"

LIBS=('libavcodec.a' 'libavdevice.a' 'libavfilter.a' 'libavformat.a' 'libavutil.a' 'libpostproc.a' 'libswresample.a' 'libswscale.a')
ARCHS=('armv7' 'armv7s' 'i386')

DEVELOPER_ROOT='/Applications/Xcode.app/Contents/Developer'
SDK_VERSION='6.1'
#CC="$DEVELOPER_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

CPU_CORE_COUNT=`sysctl -n machdep.cpu.core_count` #检测CPU核心数
MAKE_JOBS=$((CPU_CORE_COUNT+1))

function build_with_args() {
	local arch=$1
	local platform=$2
	local cc=$3
	local external_config_args=$4
	local ios_dev_root="$DEVELOPER_ROOT/Platforms/iPhone$platform.platform/Developer"
	local ios_sdk_root="$ios_dev_root/SDKs/iPhone$platform$SDK_VERSION.sdk"
	local framework_search_path="$ios_sdk_root/System/Library/Frameworks"
    local private_framework_search_path="$ios_sdk_root/System/Library/PrivateFrameworks"

	if [ -d $FFMPEG_ROOT ]; then
		echo "<<<<<<<<<<<<<<<<<<Cleaning $FFMPEG_ROOT ..."
		rm -rf $FFMPEG_ROOT    #为保证平台之间不会相互影响，在这里进行清空和重解压
		echo ">>>>>>>>>>>>>>>>>>Clean $FFMPEG_ROOT completed!"
	fi
	echo "Decompressing $FFMPEG_SRC_PACK ..."
	tar -xzf $FFMPEG_SRC_PACK
	echo "Decompress $FFMPEG_SRC_PACK completed!"
	cd $FFMPEG_ROOT

	export CC="$cc"
	#export CPP="$ios_dev_root/usr/bin/llvm-g++"
	#export PATH=":$PATH"


	local wating_time=10s 
	# 为避免脚本执行时出现如下错误，这里设定延迟时间：
	# checking whether build environment is sane... configure: error: newly created file is older than distributed files!
	# Check your system clock
	echo "Waiting $wating_time ..."
	sleep $wating_time

	./configure \
	--prefix="$BUILD_PATH/$arch" \
	--arch=$arch \
	--target-os=darwin \
	--cc="$CC" \
	--as="/usr/local/bin/gas-preprocessor.pl $CC" \
	--sysroot=$ios_sdk_root \
	--extra-cflags="-arch $arch -I$ios_sdk_root/usr/include -I$EXTERNAL_HEADER_SEARCH_PATH" \
	--extra-ldflags="-arch $arch -isysroot $ios_sdk_root -L$ios_sdk_root/usr/lib -L$ios_sdk_root/usr/lib/system -L$EXTERNAL_LIBRARY_SEARCH_PATH" \
	--disable-doc \
	--disable-ffmpeg \
	--disable-ffplay \
	--disable-ffserver \
	--disable-ffprobe \
	--disable-debug \
	--disable-armv5te \
	--disable-armv6 \
	--disable-armv6t2 \
	--enable-cross-compile \
	--enable-gpl \
	--enable-version3 \
	--enable-nonfree \
	--enable-gray \
	--enable-vda \
	--enable-avisynth \
	--enable-libx264 \
	--enable-libmp3lame \
	--enable-libtwolame \
	--enable-libopencore-amrnb \
	--enable-libopencore-amrwb \
	--enable-libvo-aacenc \
	--enable-libvo-amrwbenc \
	--enable-libfdk-aac $external_config_args

	echo "Building for $arch ..."

	make -j $MAKE_JOBS
	make install
	#	make clean #

	echo "Build for $arch completed!"

	cd -
}

function build_armv7() {
	build_with_args \
		'armv7' \
		'OS' \
		"$DEVELOPER_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
		#'--enable-libvpx'
	
}

function build_armv7s() {
	build_with_args \
		'armv7s' \
		'OS' \
		"$DEVELOPER_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
}

function build_i386() {
	build_with_args \
		'i386' \
		'Simulator' \
		"$DEVELOPER_ROOT/Platforms/iPhoneSimulator.platform/Developer/usr/bin/gcc"
		#'--enable-libvpx'
	
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
		args=''
	done

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

echo '>>>>>>>>>>>>>>>>>All completed!<<<<<<<<<<<<'

exit 0