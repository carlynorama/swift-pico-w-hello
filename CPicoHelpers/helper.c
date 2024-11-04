//#include "hardware/i2c.h"

int addNumbers(int a, int b) {
    return a + b;
}


int defaultI2CDefined() {
    return 0; //PICO_DEFAULT_I2C_SDA_PIN;
    //return defined(PICO_DEFAULT_I2C_SDA_PIN);
    //return defined(i2c_default);
}