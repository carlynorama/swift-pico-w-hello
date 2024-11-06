
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

        while true {
            //led.set(isOn:bA.isActive)

            //TODO: as a mask? 
            if bB.isActive && bC.isActive {
                //Note, person will press one or the other first
                //wait a beat for it to settle. 
                led.set(isOn:true)
            } else {
                if bB.isActive {
                    led.dot()
                }
                if bC.isActive {
                    led.dash()
                }
                led.set(isOn:false)
            }

        }
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