
@main
struct Main {
    static func main() {
        let led = UInt32(CYW43_WL_GPIO_LED_PIN)
        if cyw43_arch_init() != 0 {
            print("Wi-Fi init failed")
            return
        }
        let dot = {
            cyw43_arch_gpio_put(led, true)
            sleep_ms(250)
            cyw43_arch_gpio_put(led, false)
            sleep_ms(250)
        }
        let dash = {
            cyw43_arch_gpio_put(led, true)
            sleep_ms(500)
            cyw43_arch_gpio_put(led, false)
            sleep_ms(250)
        }
        while true {
            dot()
            dot()
            dot()

            dash()
            dash()
            dash()

            dot()
            dot()
            dot()
        }
    }
    // static let LED_PIN:CUnsignedInt = 25;

    // static func main() {
    //     //bi_decl(bi_program_description("This is a test binary."));
    //     //bi_decl(bi_1pin_with_name(LED_PIN, "On-board LED"));

    //     stdio_init_all();

    //     gpio_init(LED_PIN);
    //     gpio_set_dir(LED_PIN, true);

    //     while true {
    //         gpio_put(LED_PIN, false);
    //         sleep_ms(500);
    //         gpio_put(LED_PIN, true);
    //         puts("Hello World Again\n");
    //         sleep_ms(1000);
    //     }
    // }
}