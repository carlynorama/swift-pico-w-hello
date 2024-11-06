
@main
struct Main {
    static func main() {
        //let led = LED(pin: 25)
        let led = OnboardLED(pin: UInt32(CYW43_WL_GPIO_LED_PIN))
        
        let bA = Button(pin: 8)
        let bB = Button(pin: 9)
        let bC = Button(pin: 28)

        guard WiFi.confirm() else {
            return
        }

        USBSerial.initHardware()

        while true {
            //led.set(isOn:bA.isActive)

            // //TODO: as a mask? 
            // if bB.isActive && bC.isActive {
            //     //Note, person will press one or the other first
            //     //wait a beat for it to settle. 
            //     led.set(isOn:true)
            // } else {
            //     if bB.isActive {
            //         led.dot()
            //     }
            //     if bC.isActive {
            //         led.dash()
            //     }
            //     led.set(isOn:false)
            // }

            // led.dot()
            // led.dash()
            // led.dot()
            // USBSerial.send("Hello World\n");
            
        let sum = addNumbers(4,1)
            for _ in (0...sum) {
                //led.dot()
        }
            USBSerial.send("Hello World 2\n");

            if I2C.setupI2C0(dataPin: 0, clockPin: 1) == true {
                USBSerial.send("i2c setup success!")
            } else {
                USBSerial.send("i2c setup: something went wrong.")
            }

            var validAddresses = I2C.scanAddressesI2C0()
            USBSerial.send("There are \(validAddresses.count) devices.")


        }
    }
}
