
@main
struct Main {

    static func main() {

        guard WiFi.confirm() else {
            return
        }
        USBSerial.initHardware()

        //expected I2C devices and their addresses
        let petalAddress = 0x00
        let touchwheelAddress = 0x54

        let bus0 = I2C(.i2c0, dataPin:0, clockPin:1)
        let bus1 = I2C(.i2c1, dataPin:26, clockPin:27)

        //turn on board LED
        //find devices on i2c busses

        //if petal run test spiral

        while true {
            USBSerial.send("Hello World\n");
            let whosThere0 = bus0.scan()
            USBSerial.send("I can see: \(whosThere0.count) devices on 0 \n");
            USBSerial.send("\(whosThere0[0])")
            USBSerial.send(whosThere0, label: "What addresses 0")

            let whosThere1 = bus1.scan()
            USBSerial.send("I can see: \(whosThere1.count) devices on 1 \n");
            USBSerial.send("\(whosThere1[0])")
            USBSerial.send(whosThere1, label: "What addresses 0")
            sleep_ms(500)

            //if petal, write various things to it based on button
            //display button status on RGB

            //if touchwheel, read touchwheel

            //if touchwheel, && petal
            //write tw value to petal

        }
    }
}


protocol BadgeSAO {
    var address:Int32 { get }
    var i2cBus:I2C.Instance? { get }
}

struct TouchwheelSAO:BadgeSAO {
    let address:Int32
    let i2cBus:I2C.Instance?

}

extension TouchwheelSAO {
    init?(expectedAddress a:Int32)  {
        let whichInstance = I2C.activeBusses.filter { i in 
            I2C.scan(i, for: a)
        }
        if whichInstance.count == 0 { return nil }
        //TODO: handle the more than 1 better.
        self.i2cBus = whichInstance[0]
        self.address = a
    }
}