#ifndef helper_h
#define helper_h

int addNumbers(int a, int b);

//Not for Swift yet. 
//int i2c_setup(i2c_inst_t instance, int sda_pin, int scl_pin, int BAUD_RATE);



int i2c_setup_i2c0(int sda_pin, int scl_pin, int baud_rate);
int i2c_i2c0_address_check(int addr);

int i2c_setup_i2c1(int sda_pin, int scl_pin, int baud_rate);
int i2c_i2c1_address_check(int addr);

#endif