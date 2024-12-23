#ifndef C_SDK_BRDIGE_H
#define C_SDK_BRDIGE_H

#include <stdbool.h>

void blocking_sleep(int ms);

int onboard_led_init(void);

// Turn the led on or off
void onboard_led_set(bool led_on);
void onboard_led_assert_init(void);

void main_loop_additions(void);


void blink_set_number();


int usb_init_hardware(void);

void usb_serial_send(const char *message);

#endif