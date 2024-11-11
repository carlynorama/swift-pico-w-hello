#ifndef PICO_SDK_BRDIGE_H
#define PICO_SDK_BRDIGE_H

#include <stdbool.h>

int pico_onboard_led_init(void);

// Turn the led on or off
void pico_onboard_led_set(bool led_on);
void pico_onboard_led_assert_init();

void pico_main_loop_additions();

#endif