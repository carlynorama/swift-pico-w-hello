
struct I2C {
// https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c

// I2C reserves some addresses for special purposes. We exclude these from the scan.
// These are any addresses of the form 000 0xxx or 111 1xxx
    static func reservedAddress(_ addr:UInt8) -> Bool {
        return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
    }

    static func setupDefault() -> Bool {
        let result = i2c_setup_default()
        if result == 0 {
            return true
        }
        return false
    }

        static func scanAddressesDefault() -> [Int] {
                    //cool, didn't think to do this in Swift before. 
            //maxAddress is top of the 7bit address space.
            // var validAddresses:[Int] = []
            // for address in (1...6) {
            //     let result = i2c_default_address_check(Int32(address))
            //     USBSerial.send("\(result)")
            //     if result > -1  {
            //         validAddresses.append(address)
            //     }
            // }

            //cool, didn't think to do this in Swift before. 
            //maxAddress is top of the 7bit address space.
            var validAddresses:[Int] = (0..<(1 << 7)).filter { a in
                i2c_default_address_check(Int32(a)) > -1
            }
            return validAddresses
    }

    //todo, instance enum? 
    //default 400kHz
    static func setupI2C0(dataPin SDA:Int32, clockPin SCL:Int32, baudRate BAUD:Int32 = 400 * 1000) -> Bool {
       let result = i2c_setup_i2c0(SDA, SCL, BAUD)
        if result == 0 {
            return true
        }
        return false
    }

    static func checkAddressI2C0(address:Int32) -> Bool {
        i2c_i2c0_address_check(Int32(address)) > -1
    }

    static func scanAddressesI2C0() -> [Int] {
        var validAddresses:[Int] = []
        for address in (0..<(1 << 7)) {
            let result = i2c_i2c0_address_check(Int32(address))
            USBSerial.send("\(result)")
            if result > -1  {
                validAddresses.append(address)
            }
        }
        return validAddresses
    }
}
