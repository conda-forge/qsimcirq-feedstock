set -ex

if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS specific commands, this only needs to happen for ARM64
    # but it doesn't hurt to do it for all MacOS builds
    OPENMP_INCLUDE_DIR=$(echo ${BUILD_PREFIX}/lib/clang/*/include)
    OpenMP_omp_LIBRARY=$(echo ${BUILD_PREFIX}/lib/libomp.dylib)
    {
        echo "set(OpenMP_INCLUDE_DIR \"${OPENMP_INCLUDE_DIR}\")"
        echo "set(OpenMP_omp_LIBRARY \"${OpenMP_omp_LIBRARY}\")"
        echo "set(OpenMP_CXX_FLAGS \"-fopenmp=libomp\")"
        echo "set(OpenMP_CXX_LIB_NAMES \"omp\")"
        echo "include_directories(\${OpenMP_INCLUDE_DIR})"
        cat CMakeLists.txt
    } > tmp-CMakeLists.txt
    mv tmp-CMakeLists.txt CMakeLists.txt
fi

# Copied from https://github.com/conda-forge/slycot-feedstock/pull/47
# because $ file ~/micromamba/envs/test5/lib/python3.9/site-packages/qsimcirq/qsim_decide.cpython-39-darwin.so
# qsim_decide.cpython-39-darwin.so: Mach-O 64-bit bundle x86_64
# and: (trimmed error message)
# ❯ python -c "import qsimcirq"
# Traceback (most recent call last):
# ImportError: dlopen(.../qsim_decide.cpython-312-darwin.so, 0x0002): 
# tried: '.../qsim_decide.cpython-312-darwin.so' (mach-o file, but is an 
# incompatible architecture (have 'x86_64', need 'arm64'))
if [ "$target_platform" = "osx-arm64" ]; then
    export CMAKE_OSX_ARCHITECTURES="arm64"
    # workaround for https://github.com/scikit-build/scikit-build/issues/589
    rm -rf $PREFIX/lib/libpython$PY_VER.dylib
    ln -sf $PREFIX/lib/libc++.dylib $PREFIX/lib/libpython$PY_VER.dylib
fi

python -m pip install . -vvv --no-deps --no-build-isolation
