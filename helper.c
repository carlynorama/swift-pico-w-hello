#include "hardware/i2c.h"
#include "hardware/gpio.h"

int addNumbers(int a, int b) {
    return a + b;
}

//I2C see:
//https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c

int i2c_setup_default(void) {
    #if !defined(i2c_default) || !defined(PICO_DEFAULT_I2C_SDA_PIN) || !defined(PICO_DEFAULT_I2C_SCL_PIN)
    #warning i2c/bus_scan example requires a board with I2C pins
        puts("Default I2C pins were not defined");
        return 1;
    #else
        // This example will use I2C0 on the default SDA and SCL pins (GP4, GP5 on a Pico)
        i2c_init(i2c_default, 100 * 1000);
        gpio_set_function(PICO_DEFAULT_I2C_SDA_PIN, GPIO_FUNC_I2C);
        gpio_set_function(PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C);
        gpio_pull_up(PICO_DEFAULT_I2C_SDA_PIN);
        gpio_pull_up(PICO_DEFAULT_I2C_SCL_PIN);
        // Make the I2C pins available to picotool
    // bi_decl(bi_2pins_with_func(PICO_DEFAULT_I2C_SDA_PIN, PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C));
        return 0;
    #endif
}

// I2C reserves some addresses for special purposes. We exclude these from the scan.
// These are any addresses of the form 000 0xxx or 111 1xxx
// Not in header because Swift should use Swift version.
bool i2c_reserved_addr(uint8_t addr) {
    return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
}

int i2c_default_address_check(int addr) {
        // Perform a 1-byte dummy read from the probe address. The function 
        // returns the number of bytes transferred if address is acknowledged.
        // If the address byte is ignored, the function returns -1.

        // Skip over any reserved addresses.
        int ret;
        uint8_t rxdata;
        if (i2c_reserved_addr(addr))
            ret = PICO_ERROR_GENERIC;
        else
            ret = i2c_read_blocking(i2c_default, addr, &rxdata, 1, false);
        
        return ret;
}

int i2c_setup_i2c0(int SDA_PIN, int SCL_PIN) {
    //SDA: GPIO0, GPIO4, GPIO8, GPIO12, GPIO16, GPIO20
    //SCL: GPIO1, GPIO5, GPIO9, GPIO13, GPIO17, GPIO21
    //instance, baudrate
    i2c_init(i2c0, 400 * 1000);
    gpio_set_function(SDA_PIN, GPIO_FUNC_I2C);
    gpio_set_function(SCL_PIN, GPIO_FUNC_I2C);
    gpio_pull_up(SDA_PIN);
    gpio_pull_up(SCL_PIN);
    // Make the I2C pins available to picotool
    //bi_decl(bi_2pins_with_func(PICO_DEFAULT_I2C_SDA_PIN, PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C));

}
