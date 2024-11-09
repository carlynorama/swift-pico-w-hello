#ifndef helper_h
#define helper_h

int addNumbers(int a, int b);

//Not for Swift yet. 
//int i2c_setup(i2c_inst_t instance, int sda_pin, int scl_pin, int BAUD_RATE);

uint8_t fetch_touchwheel();

int i2c_setup_i2c0(int sda_pin, int scl_pin, int baud_rate);
int i2c_i2c0_address_check(uint8_t addr);
int i2c_write_i2c0(uint8_t addr, const uint8_t *src, int len, bool nostop);
int i2c_read_i2c0(uint8_t addr, uint8_t *dst, int len, bool nostop);
int i2c_write_read_i2c0(uint8_t addr, const uint8_t *src, int src_len, uint8_t *dst, int dst_len);

int i2c_setup_i2c1(int sda_pin, int scl_pin, int baud_rate);
int i2c_i2c1_address_check(uint8_t addr);
int i2c_write_i2c1(uint8_t addr, const uint8_t *src, int len, bool nostop);
int i2c_read_i2c1(uint8_t addr, uint8_t *dst, int len, bool nostop);
int i2c_write_read_i2c1(uint8_t addr, const uint8_t *src, int src_len, uint8_t *dst, int dst_len);



#endif