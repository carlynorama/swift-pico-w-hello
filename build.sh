# run as . ./build.sh to export values into same context. To test look for the 
# below vairable with env. 
#export TESTSHELL="hello"

TOOLCHAINLOC='/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2024-10-30-a.xctoolchain'
BOARD='pico_w'
SDK_PATH=/Users/$USER/Developer/pico-dev/pico-sdk
ARM_TOOLS=$HOMEBREW_REPOSITORY/bin
echo $SDK_PATH
echo $ARM_TOOLS


# Determine file paths
REPOROOT=$(git rev-parse --show-toplevel)
SRCROOT=$REPOROOT
BUILDROOT=$SRCROOT/.build
echo $BUILDROOT

# python3 -m venv .venv
# source .venv/bin/activate
# python3 -m pip install --upgrade pip
# python3 -m pip install -r $REPOROOT/Tools/requirements.txt

export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw -o - $TOOLCHAINLOC/Info.plist)
export PICO_BOARD=$BOARD
export PICO_SDK_PATH=$SDK_PATH
export PICO_TOOLCHAIN_PATH=$ARM_TOOLS

#env
# mkdir -p $BUILDROOT
# cd $BUILDROOT
# cmake .. -DPICO_BOARD=pico_w
# make
# cd ../

cmake -B build -G Ninja .
cmake --build build
#
#cp build/swift-blinky.uf2 /Volumes/RP2040