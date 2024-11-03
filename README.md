Getting to Hello World with Swift on the Pico W on the SuperCon badge...

Works! Most of the code as is from [the example](https://github.com/apple/swift-embedded-examples/tree/60a648b28066a56d7b1b303923895105e3b753da/pico-w-blink-sdk), but using the CMakeLists.txt from https://github.com/apple/swift-embedded-examples/pull/63 which at time of writing was not on main. 

## To Use

- get the [swift nightly toolchain](https://apple.github.io/swift-matter-examples/tutorials/swiftmatterexamples/setup-macos/) and change the name in build.sh to the nightly being used. 
- make sure the pico SDK location in build.sh is the same as your pico SDK location.
- attach the pico-w to the computer holding down the BOOTSEL and confirm the name of the volume is the same as the one in the build.sh
- set the permissions on the build.sh script (`chmod 755 build.sh`)and run as current shell `. ./build.sh`



## Useful Links

- https://github.com/apple/swift-embedded-examples/tree/main
- https://github.com/apple/swift-embedded-examples/tree/main/pico-w-blink-sdk
- https://apple.github.io/swift-matter-examples/tutorials/swiftmatterexamples/setup-macos/
- https://github.com/Hack-a-Day/2024-Supercon-8-Add-On-Badge
- https://github.com/todbot/TouchwheelSAO
- https://datasheets.raspberrypi.com/pico/getting-started-with-pico.pdf
- https://github.com/apple/swift-embedded-examples/issues/59#issuecomment-2343265666
- https://github.com/apple/swift-embedded-examples/issues/62
- https://github.com/apple/swift-embedded-examples/pull/63
- https://github.com/apple/swift-matter-examples/blob/main/empty-template/main/CMakeLists.txt
- https://www.swift.org/getting-started/embedded-swift/
- https://www.digikey.com/en/maker/projects/raspberry-pi-pico-rp2040-i2c-example-with-micropython-and-cc/47d0c922b79342779cdbd4b37b7eb7e2
- https://www.raspberrypi.com/documentation/pico-sdk/hardware.html#group_hardware_i2c
- https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c
- https://github.com/raspberrypi/pico-examples/blob/master/CMakeLists.txt
- https://forums.swift.org/t/embedded-swift-running-on-the-raspberry-pi-pico/69001/26?page=2
- https://github.com/navanchauhan/SwiftLVGL
- https://www.raspberrypi.com/documentation/pico-sdk/hardware.html#hardware_gpio
- https://github.com/raspberrypi/pico-sdk/blob/master/src/rp2_common/pico_cyw43_arch/include/pico/cyw43_arch.h


## Fixing Posix Memalign


Whats the deal: 
- https://stackoverflow.com/questions/6563120/what-does-posix-memalign-memalign-do
- https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/functions/posix_memalign.html

- Can't add -Xcc -std=c99 b/c SDK doesn't follow that?? Maybe also TODO: check if C11 (https://stackoverflow.com/a/53630273) 
- Not tried: flatalloc https://stackoverflow.com/a/68010104
- https://electronics.stackexchange.com/questions/467382/e2-studio-undefined-reference-to-posix-memalign/467753
- https://forums.swift.org/t/embedded-swift-running-on-the-raspberry-pi-pico/69001/28
    - https://gist.github.com/navanchauhan/0641c902e4a754cba6cc6b553616072f

In the end:
https://github.com/apple/swift-playdate-examples/blob/749dd8f518429168d03e754764afb334a80b527d/Sources/Playdate/Playdate.swift#L21


