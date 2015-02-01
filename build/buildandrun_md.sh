#!/bin/bash
./build.sh

cd mess
mess64 megadriv -cart ../out/untitled_megadrive.bin -window -waitvsync -nofilter -skip_gameinfo
