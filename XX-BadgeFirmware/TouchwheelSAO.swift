
struct TouchwheelSAO:BadgeSAO {
    let address:UInt8
    let i2cBus:I2C?

}

extension TouchwheelSAO {
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

    //from SAO firmware 
    //https://github.com/todbot/TouchwheelSAO/blob/main/firmware/TouchwheelSAO_attiny816/TouchwheelSAO_attiny816.ino
    enum Register:UInt8 { 
        case REG_POSITION = 0   // angular position 1-255 of touch, or 0 if no touch
        case REG_TOUCHES  = 1   // bitfield of three booleans, one for each touch pad
        case REG_RAW0L    = 2   // touchpad 0 raw count, low byte
        case REG_RAW0H    = 3   // touchpad 0 raw count, high byte
        case REG_RAW1L    = 4
        case REG_RAW1H    = 5
        case REG_RAW2L    = 6
        case REG_RAW2H    = 7
        case REG_THRESH0L = 8  // touchpad 0 threshold, low byte
        case REG_THRESH0H = 9  // touchpad 0 threshold, high byte
        case REG_THRESH1L = 10
        case REG_THRESH1H = 11  
        case REG_THRESH2L = 12
        case REG_THRESH2H = 13
        case REG_LED_STATUS = 14 // boolean to set status LED
        case REG_LED_RGBR = 15   // LED ring color R
        case REG_LED_RGBG = 16   // LED ring color G
        case REG_LED_RGBB = 17   // LED ring color B 
        case REG_NUMREGS  = 18
        case REG_NONE     = 255
    }

    //TODO: Throw? 
    func readWheel() -> UInt8 {
        //return fetch_touchwheel()
        if let i2cBus {
            //TODO, confirm return length of array was 1?
            let result = i2cBus.readValue(from:address, at:Register.REG_POSITION.rawValue, length:1)
            // if result.count > 1 {
            //     USBSerial.send("read result is too long. ")
            // }
            return result[0]
        } 
        return 0
    }

    func setColor(r:UInt8, g:UInt8, b:UInt8) {
        if let i2cBus {
            i2cBus.writeSequence([(r, Register.REG_LED_RGBR.rawValue),
                                (g, Register.REG_LED_RGBG.rawValue),
                                (b, Register.REG_LED_RGBB.rawValue)
                                ], for:address)
        }
    }

    func onStatusLED() {
        if let i2cBus {
            i2cBus.write(1, at:Register.REG_LED_STATUS.rawValue, for:address)
        }
        
    }

    func offStatusLED() {
        if let i2cBus {
            i2cBus.write(0, at:Register.REG_LED_STATUS.rawValue, for:address)
        }
    }
}