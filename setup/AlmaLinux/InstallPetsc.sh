#!/bin/bash

git clone -b release https://gitlab.com/petsc/petsc.git /opt/petsc
cd /opt/petsc
git pull # obtain new release fixes (since a prior clone or pull)

module load mpi/openmpi-x86_64

./configure --with-scalar-type=complex --with-64-bit-indices=1 --with-openmp=1 --with-fortran-bindings=0 --with-fc=0 --with-debugging=1
make PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-debug all

./configure --with-scalar-type=complex --with-64-bit-indices=1 --with-openmp=1 --with-fortran-bindings=0 --with-fc=0 --with-debugging=0 COPTFLAGS="-O3 -march=native -mtune=native" CXXOPTFLAGS="-O3 -march=native -mtune=native" 
make PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-opt all
