
@main
struct Main {
    static func blink(led: some DigitalIndicator, onTime:Int32, offTime:Int32) {
        led.set(isOn: true)
        blocking_sleep(onTime);
        led.set(isOn: false)
        blocking_sleep(offTime);
    }

    static func main() {
        //MARK: SETUP
        let statusLED = OnboardLED()
        USBSerial.initHardware()

        blink_set_number() //uses function passed into the C from Swift
        blocking_sleep(1000);

        //MARK: LOOP
        while (true) {
            blink(led: statusLED, onTime:250, offTime: 250)
            USBSerial.send("Hello World")     
        }

    }
}

@_cdecl("PassToSDKModule")
func doesThisStillWork(x: Int32) -> Int32 {
    5 + x
}


protocol DigitalIndicator {
    func set(isOn:Bool) 
}

struct OnboardLED:DigitalIndicator {
    init() {
        //handle the result code yourself. 
        //let _ = pico_onboard_led_init()
        //will crash program if can't find LED
        onboard_led_assert_init() 
    }

    func set(isOn:Bool) {
        onboard_led_set(isOn)
    } 

}

struct USBSerial {
    static func initHardware() {
        let _ = usb_init_hardware()
    }

    static func send(_ message:StaticString) {
        //usb_serial_send(c)
        message.withUTF8Buffer { bufferPointer in
            usb_serial_send(bufferPointer.baseAddress!)
        }
    }
}

