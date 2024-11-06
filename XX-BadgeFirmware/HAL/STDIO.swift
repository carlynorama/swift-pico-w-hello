
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
