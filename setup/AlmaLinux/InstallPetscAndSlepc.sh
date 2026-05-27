#!/bin/bash

module load mpi/openmpi-x86_64

git clone -b release https://gitlab.com/petsc/petsc.git /opt/petsc
cd /opt/petsc
git pull

./configure --with-scalar-type=complex --with-64-bit-indices=1 --with-openmp=1 --with-fortran-bindings=0 --with-fc=0 --with-debugging=1
make PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-debug all

./configure --with-scalar-type=complex --with-64-bit-indices=1 --with-openmp=1 --with-fortran-bindings=0 --with-fc=0 --with-debugging=0 COPTFLAGS="-O3 -march=native -mtune=native" CXXOPTFLAGS="-O3 -march=native -mtune=native" 
make PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-opt all

git clone -b release https://gitlab.com/slepc/slepc /opt/slepc
cd /opt/slepc
git pull

PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-debug ./configure
make SLEPC_DIR=/opt/slepc PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-debug

PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-opt ./configure
make SLEPC_DIR=/opt/slepc PETSC_DIR=/opt/petsc PETSC_ARCH=arch-linux-c-opt
