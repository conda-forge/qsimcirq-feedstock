set -ex

if [[ "$OSTYPE" == "darwin"* ]]; then
    # MacOS specific commands, this only needs to happen for ARM64
    # but it doesn't hurt to do it for all MacOS builds
    OPENMP_INCLUDE_DIR=$(echo ${BUILD_PREFIX}/lib/clang/*/include)
    {
        echo "set(OpenMP_INCLUDE_DIR \"${OPENMP_INCLUDE_DIR}\")"
        echo "include_directories(\${OpenMP_INCLUDE_DIR})"
        cat CMakeLists.txt
    } > tmp-CMakeLists.txt
    mv tmp-CMakeLists.txt CMakeLists.txt
fi

python -m pip install . -vvv --no-deps --no-build-isolation
