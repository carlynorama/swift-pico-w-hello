
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

    static func send(_ c:UnsafePointer<CChar>) {
        usb_serial_send(c)
    }
}


/// Implement `posix_memalign(3)`, which is required by the Swift runtime but is
/// not provided by the pico-sdk library which does not support C-99
//from search for posix_memalign using language Swift
// https://github.com/apple/swift-playdate-examples/blob/749dd8f518429168d03e754764afb334a80b527d/Sources/Playdate/Playdate.swift#L21
@_documentation(visibility: internal)
@_cdecl("posix_memalign")
public func posix_memalign(
  _ memptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
  _ alignment: Int,
  _ size: Int
) -> CInt {
  guard let allocation = malloc(Int(size + alignment - 1)) else {
    #if hasFeature(Embedded)
    fatalError()
    #else
    fatalError("Unable to handle memory request: Out of memory.")
    #endif
  }
  let misalignment = Int(bitPattern: allocation) % alignment
  #if hasFeature(Embedded)
  precondition(misalignment == 0)
  #else
  precondition(
    misalignment == 0,
    "Unable to handle requests for over-aligned memory.")
  #endif
  memptr.pointee = allocation
  return 0
}