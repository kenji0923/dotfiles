#!/bin/bash

sudo dnf install libX11-devel libXpm-devel libXft-devel libXext-devel fftw3-devel gsl-devel
rm -rf *
cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/local/root -Dgnuinstall=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo -Dfftw3=ON -Dmathmore=ON -Dqt6web=ON -Dxrootd=OFF
