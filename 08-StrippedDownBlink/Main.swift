
@main
struct Main {

    static func main() {
        //MARK: SETUP
        pico_onboard_led_assert_init()

        //MARK: LOOP
        while (true) {
            pico_main_loop_additions()
        }

    }
}