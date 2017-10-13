Point the cmake build system to Simit like so:

    export SIMIT_INCLUDE_DIR=<path to simit src dir>
    export SIMIT_LIBRARY_DIR=<path to simit lib dir>

Build the crowd_sim code as:

    mkdir build
    cd build
    cmake ..
    make

TOOD: integrate the shared library compilation into the CMake build script

Run the explicit springs example like so:

    ./crowd_sim ../basic.sim ../../data/tet-bunny/bunny.1

The springs code run for 100 time steps and leave 100 .obj files in
your build directory.

