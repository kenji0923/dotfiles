#!/bin/bash

sudo apt install gcc g++ cmake libx11-dev libxpm-dev libxft-dev libxext-dev libpython3-dev python3-numpy libglu1-mesa-dev libglew-dev libxrootd-dev libxrootd-client-dev libfftw3-dev libgsl-dev qt6-* qml6-*
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/root -Dgnuinstall=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -Dfftw3=ON -Dmathmore=ON -Dqt6web=ON
