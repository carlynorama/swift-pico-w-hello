#ifndef helper_h
#define helper_h

int addNumbers(int a, int b);

int i2c_setup_default(void);
int i2c_default_address_check(int addr);
int i2c_setup_i2c0(int SDA_PIN, int SCL_PIN, int BAUD_RATE);
int i2c_i2c0_address_check(int addr);

#endif