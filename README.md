Getting to Hello World with Swift on the Pico W on the SuperCon badge...

Works! Most of the code as is from [the example](https://github.com/apple/swift-embedded-examples/tree/60a648b28066a56d7b1b303923895105e3b753da/pico-w-blink-sdk), but using the CMakeLists.txt from https://github.com/apple/swift-embedded-examples/pull/63 which at time of writing was not on main. 

## To Use

- get the nightly and change the name in build.sh to the nightly being used.
- set the permissions on the build.sh script and run as current shell `. ./build.sh`
- attach the badge to the computer holding down the BOOTSEL
- move the .uf2 file over to the chip

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
