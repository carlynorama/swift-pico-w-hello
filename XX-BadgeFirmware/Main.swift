

protocol BadgeSAO {
    var address:UInt8 { get }
    var i2cBus:I2C? { get }
}

@main
struct Main {

    static func main() {

        guard WiFi.confirm() else {
            return
        }
        USBSerial.initHardware()

        let led = OnboardLED()

        
        //expected I2C devices and their addresses
        let petalAddress:UInt8 = 0x00
        let touchwheelAddress:UInt8 = 0x54

        //Set up I2C busses. 
        //TODO: These are structs. Probably should be classes. 
        let bus0 = I2C(.i2c0, dataPin:0, clockPin:1)
        let bus1 = I2C(.i2c1, dataPin:26, clockPin:27)
        
        //Turn on board LED
        led.set(isOn:true)

        //Find devices on i2c busses
        
        let touchWheel = TouchwheelSAO(expectedAddress: touchwheelAddress) 
        let pinwheel = PinwheelSAO(expectedAddress: petalAddress) 
        if let pinwheel {
            //if petal do setup and run test spiral
            pinwheel.setBadgeSettings()
            pinwheel.testPattern()
            pinwheel.setMiddle(r:true, g:true, b:false)
        }

        if pinwheel != nil && touchWheel != nil {
            pinwheel!.setMiddle(r:false, g:true, b:false)
            sleep_ms(200)
        }

        //Turn off board LED

        led.set(isOn:false)

        while true {

            if let touchWheel {
                let val = touchWheel.readWheel()
                USBSerial.send("\(val)")
                // if val == 0 {
                //     touchWheel.setColor(r: 200, g: 100, b: 0)
                // }
                touchWheel.onStatusLED()
                sleep_ms(250)
                touchWheel.offStatusLED()
                sleep_ms(250)
            }
            


            //if petal, write various things to it based on button
            //display button status on RGB

            //if touchwheel, read touchwheel

            //if touchwheel, && petal
            //write tw value to petal

        }
    }
}


