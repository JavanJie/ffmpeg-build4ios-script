ffmpeg-build4ios-script
=======================

Build ffmpeg-1.2 for iOS(armv7,armv7s,i386) scripts,and some external plugins

FFMpeg libs:
============
- libavcodec
- libavdevice
- libavfilter
- libavformat
- libavutil
- libpostproc
- libswresample
- libswscale

All are available for **i386, armv7, armv7s**

Support external libs:
=========================
- aacenc(i386, armv7, armv7s)
- amrwbenc(i386, armv7, armv7s)
- opencore-amr(i386, armv7, armv7s)
- fdk-aac(i386, armv7, armv7s)
- lame(i386, armv7, armv7s)
- twolame(i386, armv7, armv7s)
- libvpx(i386, armv7)
- x264(i386, armv7, armv7s)
	

Required
========
- Xcode4.6.2 or newer
- iOS6.1 or newer
  
Build step
==========
1. Copy "gas-preprocessor.pl" from "tools/gas-preprocessor.pl" to "/usr/local/bin" `sudo cp tools/gas-preprocessor.pl /usr/local/bin/`, and then `sudo chmod 777 /usr/local/bin/gas-preprocessor.pl`. **gas-preprocessor.pl** was stolen from "http://github.com/yuvi/gas-preprocessor"
2. Install **yasm-1.2.0** (In tools/yasm-1.2.0.tar.gz). Easy to install it: `./configure`, `make`, `sudo make install`
3. Install **nasm-2.10.07** (In tools/nasm-2.10.07.tar.bz2). Easy to install it: `./configure`, `make`, `sudo make install`
4. Run script **build-all.sh** `./build-all.sh`

Have fun!
