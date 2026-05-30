#!/usr/bin/env bash
set -euo pipefail

src_dir="/tmp/elmerfem"
build_dir=""
build_after_configure=0
skip_install=0
parallel_jobs="$(nproc 2>/dev/null || echo 6)"

usage() {
  cat <<'USAGE'
Install Elmer FEM build dependencies and run CMake configure.

Defaults:
  source directory: /tmp/elmerfem
  build directory:  <source directory>/build

Options:
  --src DIR        Elmer source checkout containing CMakeLists.txt
  --build-dir DIR  CMake build directory
  --skip-install   Do not install OS packages, only configure
  --build          Run cmake --build after configure
  -j N             Parallel jobs for --build
  -h, --help       Show this help

Examples:
  ./install_configure_elmerfem.sh
  ./install_configure_elmerfem.sh --src /opt/elmerfem/src --build-dir /tmp/elmerfem-build
  ./install_configure_elmerfem.sh --skip-install --build -j 8
USAGE
}

while (($#)); do
  case "$1" in
    --src)
      src_dir="${2:?missing argument for --src}"
      shift 2
      ;;
    --build-dir)
      build_dir="${2:?missing argument for --build-dir}"
      shift 2
      ;;
    --skip-install)
      skip_install=1
      shift
      ;;
    --build)
      build_after_configure=1
      shift
      ;;
    -j)
      parallel_jobs="${2:?missing argument for -j}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

build_dir="${build_dir:-${src_dir%/}/build}"

if [[ ! -f "$src_dir/CMakeLists.txt" ]]; then
  echo "Source directory does not contain CMakeLists.txt: $src_dir" >&2
  echo "Pass --src DIR for your Elmer FEM checkout." >&2
  exit 1
fi

dnf_cmd=()
if ((skip_install == 0)); then
  if ! command -v dnf >/dev/null 2>&1; then
    echo "dnf was not found. Use --skip-install and install dependencies manually." >&2
    exit 1
  fi

  if [[ "$(id -u)" -eq 0 ]]; then
    dnf_cmd=(dnf)
  elif command -v sudo >/dev/null 2>&1; then
    dnf_cmd=(sudo dnf)
  else
    echo "Need root privileges or sudo to install packages." >&2
    exit 1
  fi

  "${dnf_cmd[@]}" install -y \
    cmake make gcc gcc-c++ gcc-gfortran \
    openmpi openmpi-devel \
    MUMPS MUMPS-devel MUMPS-openmpi MUMPS-openmpi-devel \
    scalapack-openmpi \
    metis metis-devel scotch scotch-devel ptscotch-openmpi \
    blas blas-devel lapack lapack-devel \
    qt5-devel qwt-qt5 qwt-qt5-devel \
    mesa-libGL mesa-libGLU mesa-libGLU-devel
fi

required_paths=(
  /usr/include/MUMPS/dmumps_struc.h
  /usr/lib64/openmpi/lib/libdmumps.so
  /usr/lib64/openmpi/lib/libscalapack.so.2.2
  /usr/include/scotch
  /usr/lib64/openmpi/lib/libptscotchparmetisv3.so.7.0
  /usr/include/qt5/qwt/qwt.h
  /usr/lib64/libqwt-qt5.so
  /usr/include/GL/glu.h
)

missing=()
for path in "${required_paths[@]}"; do
  [[ -e "$path" ]] || missing+=("$path")
done

if ((${#missing[@]})); then
  echo "Missing expected dependency paths:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  echo "Install the matching development packages or adjust this script for your distribution." >&2
  exit 1
fi

mpi_args=()
if [[ -x /usr/lib64/openmpi/bin/mpicc ]]; then
  mpi_args+=(
    -DMPI_C_COMPILER:FILEPATH=/usr/lib64/openmpi/bin/mpicc
    -DMPI_CXX_COMPILER:FILEPATH=/usr/lib64/openmpi/bin/mpicxx
    -DMPI_Fortran_COMPILER:FILEPATH=/usr/lib64/openmpi/bin/mpif90
    -DMPIEXEC_EXECUTABLE:FILEPATH=/usr/lib64/openmpi/bin/mpiexec
  )
fi

cmake -S "$src_dir" -B "$build_dir" \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_ELMERGUI:BOOL=TRUE \
  -DWITH_OpenMP:BOOLEAN=TRUE \
  -DWITH_MPI:BOOL=TRUE \
  -DWITH_ElmerIce:BOOLEAN=TRUE \
  -DWITH_QWT:BOOL=TRUE \
  -DQWT_INCLUDE_DIR:PATH=/usr/include/qt5/qwt \
  -DQWT_LIBRARY:FILEPATH=/usr/lib64/libqwt-qt5.so \
  -DMumps_INCLUDE_DIR:PATH=/usr/include/MUMPS \
  -DSCALAPACK_LIBRARIES:FILEPATH=/usr/lib64/openmpi/lib/libscalapack.so.2.2 \
  -DParMetis_INCLUDE_DIR:PATH=/usr/include/scotch \
  -DParMetis_LIBRARIES:FILEPATH=/usr/lib64/openmpi/lib/libptscotchparmetisv3.so.7.0 \
  "${mpi_args[@]}"

if ((build_after_configure)); then
  cmake --build "$build_dir" --parallel "$parallel_jobs"
fi

echo "Elmer FEM CMake configure completed:"
echo "  source: $src_dir"
echo "  build:  $build_dir"
