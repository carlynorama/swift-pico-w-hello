
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
                led.dot()
            }
            USBSerial.send("Hello World\n");

            if I2C.setupDefault() == true {
                USBSerial.send("i2c setup success!")
            } else {
                USBSerial.send("i2c setup: something went wrong.")
            }

            //cool, didn't think to do this in Swift before. 
            //maxAddress is top of the 7bit address space.
            var validAddresses:[Int] = []
            for address in (1...6) {
                let result = i2c_default_address_check(Int32(address))
                USBSerial.send("\(result)")
                if result > -1  {
                    validAddresses.append(address)
                }
            }

            //cool, didn't think to do this in Swift before. 
            //maxAddress is top of the 7bit address space.
            // var validAddresses:[Int] = (0..<(1 << 7)).filter { a in
            //     i2c_default_address_check(Int32(a)) > -1
            // }

            USBSerial.send("There are \(validAddresses.count) devices.")


        }
    }
}

struct USBSerial {
    static func initHardware() {
        //https://www.raspberrypi.com/documentation/pico-sdk/runtime.html#group_pico_stdio_1ga0e604311fb226dae91ff4eb17a19d67a
        //UART, USB, semihosting, and RTT based on the presence of the respective libraries in the binary.
        stdio_init_all();
    }

    static func send(_ c:UnsafePointer<CChar>) {
        //TODO: why puts and not stdio_puts
        puts(c);
    }
}

struct Button {
    let pin:UInt32

    init(pin p:UInt32, enablePullUp:Bool = true) {
        gpio_init(p);
        gpio_set_dir(p, false);
        if enablePullUp {
            gpio_pull_up(p);
        }
        self.pin = p
    }

    var isActive:Bool {
        !gpio_get(pin)
    }

    func read() -> Bool {
        gpio_get(pin)
    }
}

struct WiFi {
    static func confirm() -> Bool {
        if cyw43_arch_init() != 0 {
            return false
        }
        return true
    }
}

struct I2C {
// https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c

// I2C reserves some addresses for special purposes. We exclude these from the scan.
// These are any addresses of the form 000 0xxx or 111 1xxx
    static func reservedAddress(_ addr:UInt8) -> Bool {
        return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
    }

    static func setupDefault() -> Bool {
        let result = i2c_setup_default()
        if result == 0 {
            return true
        }
        return false
    }

    //todo, instance enum? 
    static func setupI2C0(SDA:UInt32, SCL:UInt32) -> Bool {
       let result = i2c_setup_i2c0(SDA, SCL)
        if result == 0 {
            return true
        }
        return false
    }
}


//Once you've imported cyw43_arch the regular io stops working?
//because it works in C..
struct OnboardLED {
    let pin:UInt32

    init(pin p:UInt32) {
        self.pin = p
    }

    func high() {
        cyw43_arch_gpio_put(pin, true)
    }

    func low() {
        cyw43_arch_gpio_put(pin, false)
    }

    func set(isOn:Bool) {
        //the onboard led is not sink source. 
        cyw43_arch_gpio_put(pin, isOn)
    }

    func dot() {
        cyw43_arch_gpio_put(pin, true)
        sleep_ms(250)
        cyw43_arch_gpio_put(pin, false)
        sleep_ms(250)
    }

    func dash() {
        cyw43_arch_gpio_put(pin, true)
        sleep_ms(500)
        cyw43_arch_gpio_put(pin, false)
        sleep_ms(250)
    }
}

// //TODO: why does addressing the onboard LED on the picow
// //as pin 25 work in the C, but not in the swift?
// //tried not importing cyw43_arch
// struct LED {
//     let pin:UInt32

//     init(pin p:UInt32) {
//         self.pin = p
//         gpio_init(p);
//         gpio_set_dir(p, true);
//     }

//     // func set() {
//     //     gpio_init(pin);
//     //     gpio_set_dir(pin, true);
//     // }

//     func high() {
//         gpio_put(pin, true)
//     }

//     func low() {
//         gpio_put(pin, false)
//     }

//     func dot() {
//         gpio_put(pin, true)
//         sleep_ms(250)
//         gpio_put(pin, false)
//         sleep_ms(250)
//     }

//     func dash() {
//         gpio_put(pin, true)
//         sleep_ms(500)
//         gpio_put(pin, false)
//         sleep_ms(250)
//     }

// }




/// Implement `posix_memalign(3)`, which is required by the Swift runtime but is
/// not provided by the pico-sdk library.
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