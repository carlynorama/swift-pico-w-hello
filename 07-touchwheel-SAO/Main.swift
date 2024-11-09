

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

        //expected I2C devices and their addresses
        //let petalAddress:UInt8 = 0x00
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


