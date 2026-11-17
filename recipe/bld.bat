setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: CMake-style (forward slash) site-packages path: it is embedded in generated
:: CMake code (cmake_install.cmake, ConduitConfig.cmake), where backslashes
:: are parsed as escape sequences, a hard error since CMake 4.0.
set "SP_DIR_CMAKE=%SP_DIR:\=/%"

:: Configure using the CMakeFiles
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DENABLE_PYTHON=ON ^
      -DENABLE_TESTS=OFF ^
      -DCONDUIT_ENABLE_TESTS=OFF ^
      -Dgtest_disable_pthreads=ON ^
      -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
      -DPYTHON_MODULE_INSTALL_PREFIX="%SP_DIR_CMAKE%" ^
      -DHDF5_DIR:PATH="%LIBRARY_PREFIX%" ^
      ../src
if errorlevel 1 exit 1

:: Build!
nmake VERBOSE=1
if errorlevel 1 exit 1

:: Install!
nmake install
if errorlevel 1 exit 1

:: Triumph !