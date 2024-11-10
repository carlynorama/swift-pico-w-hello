

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

        let bA = Button(pin: 8)
        let bB = Button(pin: 9)
        let bC = Button(pin: 28)

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
                if val == 0 {
                    touchWheel.setColor(r: 200, g: 100, b: 0)
                } else if let pinwheel {
                    let bladePattern = pinwheel.makeProgressByte(from: val)
                    pinwheel.setAllBlades(bladePattern)
                }
                //code needs a short sleep to let the blocking I2C pair that is 
                //a write-read do its thing, apparently. 10 allows for a good enough
                //debounce, too. 
                //sleep_ms(5)
                sleep_ms(10) 

            }

            //current firmware doesn't allow for masking just the RGB LED, so don't
            //use the touchwheel and the buttons at the same time just yet. 
            //TODO: The blades w/o RGB leds stay lit. It's a feature I swear.
            if let pinwheel {
                pinwheel.setMiddle(r:bA.isActive, g:bB.isActive, b:bC.isActive)
            }
            



            //if petal, write various things to it based on button
            //display button status on RGB

            //if touchwheel, read touchwheel

            //if touchwheel, && petal
            //write tw value to petal

        }
    }
}


