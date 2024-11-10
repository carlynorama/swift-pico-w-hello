

// 1
// 2
// 3
// 4
// 5
// 6
// 7
// 8 


struct PinwheelSAO:BadgeSAO {
    let address:UInt8
    let i2cBus:I2C?


    func setAllBlades(_ value:UInt8) {
        if let i2cBus {
            let base = 1
            for blade in base..<(base+8) {
                i2cBus.write(value, at:UInt8(blade), for:address)
            }
        }
    }

    func set(blade:UInt8, to value:UInt8) {
        if let i2cBus {
        i2cBus.write(value, at:blade, for:address)
        }
    }

    func set(blades:[UInt8], to value:UInt8) {
        if let i2cBus {
            for blade in blades {
                i2cBus.write(value, at:blade, for:address)
            }
        }
    }

    func setMiddle(r:Bool, g:Bool, b:Bool) {
        set(blades:[2], to: b ? 0b10000000 : 0) //blue
        set(blades:[3], to: r ? 0b10000000 : 0) //red
        set(blades:[4], to: g ? 0b10000000 : 0) //green
        set(blades: [1,5,6,7,8], to: 0)
    }

    func makeProgressByte(from value: UInt8) -> UInt8 {
        let howmany = value/36  //255/7 because top bit is for button indication. 
        return (255 << howmany) & 0b01111111
    }

    func testPattern() {
                set(blades:[1], to: 0b10101010)
                sleep_ms(500)
                set(blades:[1], to: 0)
                set(blades:[2], to: 0b10101010)
                sleep_ms(500)
                set(blades:[2], to: 0)
                set(blades:[3], to: 0b10101010)
                sleep_ms(500)
                set(blades:[3], to: 0)
                set(blades:[4], to: 0b10101010)
                sleep_ms(500)
                set(blades:[4], to: 0)
                set(blades:[5], to: 0b10101010)
                sleep_ms(500)
                set(blades:[5], to: 0)
                set(blades:[6], to: 0b10101010)
                sleep_ms(500)
                set(blades:[6], to: 0)
                set(blades:[7], to: 0b10101010)
                sleep_ms(500)
                set(blades:[7], to: 0)
                set(blades:[8], to: 0b10101010)
                sleep_ms(500) 
                set(blades:[8], to: 0)
                sleep_ms(500) 
    }


    
}

extension PinwheelSAO {
    init?(expectedAddress a:UInt8)  {
        USBSerial.send("Going to scan \(I2C.activeBusses.count) I2C Busses")
        let whichInstance = I2C.activeBusses.filter { i in 
            i.scan(for: a)
        }
        USBSerial.send("Found it in \(whichInstance.count) instances")
        if whichInstance.count == 0 { return nil }
        //TODO: handle the more than 1 better.
        self.i2cBus = whichInstance[0]
        self.address = a
    }

    func setBadgeSettings() {

    //    """configure the petal SAO"""
    // bus.writeto_mem(PETAL_ADDRESS, 0x09, bytes([0x00]))  ## raw pixel mode (not 7-seg) 
    // bus.writeto_mem(PETAL_ADDRESS, 0x0A, bytes([0x09]))  ## intensity (of 16) 
    // bus.writeto_mem(PETAL_ADDRESS, 0x0B, bytes([0x07]))  ## enable all segments
    // bus.writeto_mem(PETAL_ADDRESS, 0x0C, bytes([0x81]))  ## undo shutdown bits 
    // bus.writeto_mem(PETAL_ADDRESS, 0x0D, bytes([0x00]))  ##  
    // bus.writeto_mem(PETAL_ADDRESS, 0x0E, bytes([0x00]))  ## no crazy features (default?) 
    // bus.writeto_mem(PETAL_ADDRESS, 0x0F, bytes([0x00]))  ## turn off display test mode 

        if let i2cBus {
            i2cBus.write(0x00, at:0x09, for:address)
            i2cBus.write(0x09, at:0x0A, for:address)
            i2cBus.write(0x07, at:0x0B, for:address)
            i2cBus.write(0x81, at:0x0C, for:address)
            i2cBus.write(0x00, at:0x0D, for:address)
            i2cBus.write(0x00, at:0x0E, for:address)
            i2cBus.write(0x00, at:0x0F, for:address)
        }
    }

    


}



// ## waiting for wheel with a yellow light
// if petal_bus:
//     petal_bus.writeto_mem(PETAL_ADDRESS, 3, bytes([0x80]))
//     petal_bus.writeto_mem(PETAL_ADDRESS, 2, bytes([0x80]))
