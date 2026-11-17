"""Link system libraries by name in conduit's installed CMake export.

Without an HDF5 CMake config (hdf5 1.14 on unix), conduit exports the
HDF5_LIBRARIES of CMake's FindHDF5 as absolute paths, and FindHDF5
resolves system libraries (pthread, dl, m, ...) in the compiler's sysroot
of the build environment, which does not exist where the package is
installed. Absolute library paths outside the host prefix are replaced by
the bare library name, e.g. <sysroot>/usr/lib/libpthread.so -> pthread.

usage: fix_cmake_export.py <PREFIX> <BUILD_PREFIX> <export.cmake>
"""
import re
import sys
from pathlib import Path

prefix, build_prefix, export = sys.argv[1], sys.argv[2], Path(sys.argv[3])

# an entry of a CMake list in a quoted string: "...;/abs/dir/libNAME.so;..."
lib_path = re.compile(
    r'(?<=[";])/[^";]*/lib([^/";]+?)\.(?:so(?:\.[0-9]+)*|dylib|tbd|a)(?=[";])'
)


def by_name(match):
    path = match.group(0)
    if path.startswith(prefix + "/"):
        return path  # relocated by conda
    print(f"{export.name}: {path} -> {match.group(1)}")
    return match.group(1)


text = lib_path.sub(by_name, export.read_text())
export.write_text(text)

if build_prefix in text:
    sys.exit(f"{export}: still references the build environment {build_prefix}")
