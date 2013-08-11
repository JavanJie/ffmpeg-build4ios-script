#!/bin/bash

set -o errexit

cd 'external-libs'

./build-aacenc.sh

./build-amrwbenc.sh

./build-fdk-aac.sh

./build-lame.sh

./build-libvpx.sh

./build-opencore-amr.sh

./build-twolame.sh

./build-x264.sh

cd ..

./build-beautiful.sh