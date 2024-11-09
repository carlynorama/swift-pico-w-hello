
@main
struct Main {

    static func main() {

        guard WiFi.confirm() else {
            return
        }
        USBSerial.initHardware()

        //expected I2C devices and their addresses
        let petalAddress:UInt8 = 0x00
        let touchwheelAddress:UInt8 = 0x54

        let bus0 = I2C(.i2c0, dataPin:0, clockPin:1)
        let bus1 = I2C(.i2c1, dataPin:26, clockPin:27)

        //turn on board LED
        //find devices on i2c busses

        //if petal run test spiral
        
        
        let touchWheel = TouchwheelSAO(expectedAddress: touchwheelAddress) 
        if touchWheel != nil {
                USBSerial.send("made a touchWheel")
        }

        while true {
            // USBSerial.send("Hello World\n");
            // let whosThere0 = bus0.scan()
            // USBSerial.send("I can see: \(whosThere0.count) devices on 0 \n");
            // USBSerial.send("\(whosThere0[0])")
            // USBSerial.send(whosThere0, label: "What addresses 0")
            // let found0 = bus0.scan(for: whosThere0[0]) 
            // if found0 {
            //     USBSerial.send("\(found0)")
            // } else {
            //     USBSerial.send("scan for doesn't work")
            // }

            // let whosThere1 = bus1.scan()
            // USBSerial.send("I can see: \(whosThere1.count) devices on 1 \n");
            // USBSerial.send("\(whosThere1[0])")
            // USBSerial.send(whosThere1, label: "What addresses 0")

            if let touchWheel {
                touchWheel.onStatusLED()
                sleep_ms(250)
                touchWheel.offStatusLED()
                sleep_ms(500)
            }
            


            //if petal, write various things to it based on button
            //display button status on RGB

            //if touchwheel, read touchwheel

            //if touchwheel, && petal
            //write tw value to petal

        }
    }
}


protocol BadgeSAO {
    var address:UInt8 { get }
    var i2cBus:I2C? { get }
}

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

    func readWheel() -> UInt8 {
        return 0
    }

    func setColor(r:UInt8, g:UInt8, b:UInt8) {

    }

    func onStatusLED() {
        if let i2cBus {
            i2cBus.write(1, toRegister:Register.REG_LED_STATUS.rawValue, at:address)
        }
        
    }

    func offStatusLED() {
        if let i2cBus {
            i2cBus.write(0, toRegister:Register.REG_LED_STATUS.rawValue, at:address)
        }
    }
}