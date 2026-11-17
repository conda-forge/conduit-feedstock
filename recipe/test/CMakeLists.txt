# Smoke test of the installed package from a downstream CMake project:
# find_package(Conduit) loads ConduitConfig.cmake and its dependencies
# (HDF5, ZLIB), then build and run a program against conduit::conduit.
cmake_minimum_required(VERSION 3.26)
project(conduit_smoke LANGUAGES C CXX)

find_package(Conduit REQUIRED)
message(STATUS "Conduit ${Conduit_VERSION}: ${Conduit_DIR}")
message(STATUS "CONDUIT_PYTHON_EXECUTABLE: ${CONDUIT_PYTHON_EXECUTABLE}")
message(STATUS "CONDUIT_PYTHON_MODULE_DIR: ${CONDUIT_PYTHON_MODULE_DIR}")

add_executable(conduit_smoke conduit_smoke.cpp)
target_link_libraries(conduit_smoke PRIVATE conduit::conduit)
