# run as . ./build.sh to export values into same context. To test look for the 
# below vairable with env. 
#export TESTSHELL="hello"

## Note, toolchain was installed for all users.
## /Users/$USER/Library/Developer/Toolchains/ for local only
TOOLCHAINLOC='/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2024-10-30-a.xctoolchain'
BOARD='pico_w'
SDK_PATH=/Users/$USER/Developer/pico-dev/pico-sdk
ARM_TOOLS=$HOMEBREW_REPOSITORY/bin
DESTINATION=/Volumes/RPI-RP2
EXPECTED_EXECUTABLE=swift-blinky.uf2
echo $SDK_PATH
echo $ARM_TOOLS


# Determine file paths
REPOROOT=$(git rev-parse --show-toplevel)
SRCROOT=$REPOROOT/02-Switch
BUILDROOT=$SRCROOT/build
echo $BUILDROOT

export TOOLCHAINS=$(plutil -extract CFBundleIdentifier raw -o - $TOOLCHAINLOC/Info.plist)
export PICO_BOARD=$BOARD
export PICO_SDK_PATH=$SDK_PATH
export PICO_TOOLCHAIN_PATH=$ARM_TOOLS

#env

# Ninjaless
mkdir -p $BUILDROOT
cd $BUILDROOT
cmake .. -DPICO_BOARD=pico_w
make
cd ../

# cmake -B $BUILDROOT -G Ninja .
# cmake --build $BUILDROOT


#cp $BUILDROOT/$EXPECTED_EXECUTABLE $DESTINATION