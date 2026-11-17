#!/bin/bash

# Setup CMake build location
rm -rf build
mkdir build
cd build

# MPI variants
if [[ ${mpi} == "nompi" ]]; then
   export ENABLE_MPI="OFF"
else
   export ENABLE_MPI="ON"
fi


# configure with cmake
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DENABLE_PYTHON=ON \
      -DPYTHON_EXECUTABLE:FILEPATH=$(which ${PYTHON}) \
      -DENABLE_FORTRAN=ON \
      -DENABLE_MPI=$ENABLE_MPI \
      -DPYTHON_MODULE_INSTALL_PREFIX=${SP_DIR} \
      -DHDF5_DIR=${PREFIX} \
      ../src

# build, test, and install
make

###############################################
# Run tests during build when on linux w/o mpi
###############################################
# skip running tests during build if mpi is on
# 
# rsh/ssh don't exist in build containers
# so mpiexec fails to launch our tests
###############################################
# skip tests by default
export RUN_TESTS="OFF"

# run tests when mpi is on
if [[ ${ENABLE_MPI} == "OFF" ]]; then
    export RUN_TESTS="ON"
fi

# skip tests on macos
if [[ "$OSTYPE" == "darwin"* ]]; then
    export RUN_TESTS="OFF"
fi

if [[ ${RUN_TESTS} == "ON" ]]; then
     env CTEST_OUTPUT_ON_FAILURE=1 make test
fi

make install

# the installed CMake export must not link libraries from the build
# environment or the macOS SDK, which do not exist where the package is
# installed (LLNL/conduit#1733)
for build_path in "${BUILD_PREFIX}" "${CONDA_BUILD_SYSROOT:-}"; do
    if [[ -n "${build_path}" ]] && grep -nF "${build_path}" "${PREFIX}/lib/cmake/conduit/conduit.cmake"; then
        echo "conduit.cmake references ${build_path}"
        exit 1
    fi
done
