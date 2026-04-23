@echo on
setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G Ninja ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DENABLE_PYTHON=ON ^
      -DENABLE_TESTS=OFF ^
      -DCONDUIT_ENABLE_TESTS=OFF ^
      -Dgtest_disable_pthreads=ON ^
      -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
      -DPYTHON_MODULE_INSTALL_PREFIX="%SP_DIR:\=/%" ^
      -DHDF5_DIR:PATH="%LIBRARY_PREFIX%" ^
      ../src
if %ERRORLEVEL% NEQ 0 exit 1

:: Build!
cmake --build .
if %ERRORLEVEL% NEQ 0 exit 1

:: Install!
cmake --install .
if %ERRORLEVEL% NEQ 0 exit 1

:: Triumph !
