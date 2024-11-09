#include <stdint.h>
#include <stdbool.h>
#include "helper.h"
#include "hardware/i2c.h"
#include "hardware/gpio.h"

// Vestigal. Used for proof of correct connection to Swift code.
// int addNumbers(int a, int b) {
//     return a + b;
// }


// I2C reserves some addresses for special purposes. We exclude these from the scan.
// These are any addresses of the form 000 0xxx or 111 1xxx
// Not in header because Swift should use Swift version.
bool i2c_reserved_addr(uint8_t addr) {
    return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
}

//Default not visible to Swift I2C example for now. 

//I2C see:
//https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c

// int i2c_setup_default(void) {
//     #if !defined(PICO_DEFAULT_I2C_SDA_PIN) || !defined(PICO_DEFAULT_I2C_SCL_PIN)
//     #warning i2c/bus_scan example requires a board with I2C pins
//         return 1;
//     #else
//         return i2c_setup(i2c_default, PICO_DEFAULT_I2C_SDA_PIN, PICO_DEFAULT_I2C_SCL_PIN, 400 * 1000);
//     #endif
// }



// int i2c_default_address_check(int addr) {
//         // Perform a 1-byte dummy read from the probe address. The function 
//         // returns the number of bytes transferred if address is acknowledged.
//         // If the address byte is ignored, the function returns -1.

//         // Skip over any reserved addresses.
//         int ret;
//         uint8_t rxdata;
//         if (i2c_reserved_addr(addr))
//             ret = PICO_ERROR_GENERIC;
//         else
//             ret = i2c_read_blocking(i2c_default, addr, &rxdata, 1, false);
        
//         return ret;
// }

//--------- SETUPS
//Note should I add i2c_set_slave_mode(_i2c_dev, false, 0); ?
int i2c_setup(i2c_inst_t *i2c, int sda_pin, int scl_pin, int baud_rate) {
        gpio_set_function(sda_pin, GPIO_FUNC_I2C);
        gpio_set_function(scl_pin, GPIO_FUNC_I2C);
        gpio_pull_up(sda_pin);
        gpio_pull_up(scl_pin);
        //instance, baudrate
        //TODO: Can this fail? func returns uint
        i2c_init(i2c, baud_rate);
        // Make the I2C pins available to picotool
        //bi_decl(bi_2pins_with_func(PICO_DEFAULT_I2C_SDA_PIN, PICO_DEFAULT_I2C_SCL_PIN, GPIO_FUNC_I2C));
        return 0;
}

int i2c_setup_i2c0(int sda_pin, int scl_pin, int baud_rate) {
    //TODO, check for valid? 
    //SDA: GPIO0, GPIO4, GPIO8, GPIO12, GPIO16, GPIO20
    //SCL: GPIO1, GPIO5, GPIO9, GPIO13, GPIO17, GPIO21
    #if !defined(i2c0)
    #warning i2c/bus_scan example requires a board with I2C pins
        puts("I2C instance not defined in SDK");
        return 1;
    #else
        return i2c_setup(i2c0, sda_pin, scl_pin, baud_rate);
    #endif
    
}

int i2c_setup_i2c1(int sda_pin, int scl_pin, int baud_rate) {
    //TODO, check for valid? 
    //SDA:
    //SCL: 
    #if !defined(i2c1)
    #warning i2c/bus_scan example requires a board with I2C pins
        puts("I2C instance not defined in SDK");
        return 1;
    #else
        i2c_setup(i2c1, sda_pin, scl_pin, baud_rate);
    #endif
}

//--------- ADDRESS CHECKS
int i2c_address_check(i2c_inst_t *i2c, uint8_t addr) {
        // Perform a 1-byte dummy read from the probe address. The function 
        // returns the number of bytes transferred if address is acknowledged.
        // If the address byte is ignored, the function returns -1.

        // Skip over any reserved addresses.
        // int ret;
        uint8_t rxdata;
        // if (i2c_reserved_addr(addr))
        //     ret = PICO_ERROR_GENERIC;
        // else
        //    ret = 
        
        return i2c_read_blocking(i2c, addr, &rxdata, 1, false);;
}

int i2c_i2c0_address_check(uint8_t addr) {
    i2c_address_check(i2c0, addr);
}

int i2c_i2c1_address_check(uint8_t addr) {
    i2c_address_check(i2c1, addr);
}

//----------- BASIC WRITE

int i2c_write_i2c0(uint8_t addr, const uint8_t *src, int len, bool nostop) {
    i2c_write_blocking(i2c0, addr, src, len, nostop);
}

int i2c_write_i2c1(uint8_t addr, const uint8_t *src, int len, bool nostop) {
    i2c_write_blocking(i2c1, addr, src, len, nostop);
}

//----------- BASIC READ

int i2c_read_i2c0(uint8_t addr, uint8_t *dst, int len, bool nostop) {
    i2c_read_blocking(i2c0, addr, dst, len, nostop);
}

int i2c_read_i2c1(uint8_t addr, uint8_t *dst, int len, bool nostop) {
    i2c_read_blocking(i2c1, addr, dst, len, nostop);
}

//---------- Read Value

int i2c_write_read_i2c0(uint8_t addr, const uint8_t *src, int src_len, uint8_t *dst, int dst_len) {
    i2c_write_blocking(i2c0, addr, src, src_len, true);
    i2c_read_blocking(i2c0, addr, dst, dst_len, false);
}

int i2c_write_read_i2c1(uint8_t addr, const uint8_t *src, int src_len, uint8_t *dst, int dst_len) {
    i2c_write_blocking(i2c1, addr, src, src_len, true);
    i2c_read_blocking(i2c1, addr, dst, dst_len, false);
}


// for trouble shooting write-read-nostop issue which magically resolved itself. gremlins. 
// uint8_t fetch_touchwheel() {
//     uint8_t reg = 0;
//     uint8_t dst = 0;
//     i2c_write_blocking(i2c1, 0x54, &reg, 1, true);
//     i2c_read_blocking(i2c1, 0x54, &dst, 1, false);
//     return dst;
//}

// void lis3dh_read_data(uint8_t reg, float *final_value) {
//     // Read two bytes of data and store in a 16 bit data structure
//     uint8_t lsb;
//     uint8_t msb;
//     uint16_t raw_accel;
//     i2c_write_blocking(i2c_default, ADDRESS, &reg, 1, true);
//     i2c_read_blocking(i2c_default, ADDRESS, &lsb, 1, false);

//     reg |= 0x01;
//     i2c_write_blocking(i2c_default, ADDRESS, &reg, 1, true);
//     i2c_read_blocking(i2c_default, ADDRESS, &msb, 1, false);

//     raw_accel = (msb << 8) | lsb;

//     lis3dh_calc_value(raw_accel, final_value, IsAccel);
// }