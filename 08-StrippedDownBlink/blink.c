// Based on https://github.com/raspberrypi/pico-examples/tree/master/blink
// Which was released with the BSD-3-Clause

#include "pico/stdlib.h"
#include <stdbool.h>

// Pico W devices use a GPIO on the WIFI chip for the LED,
// so when building for Pico W, CYW43_WL_GPIO_LED_PIN will be defined
#ifdef CYW43_WL_GPIO_LED_PIN
#include "pico/cyw43_arch.h"
#endif


#ifndef LED_DELAY_MS
#define LED_DELAY_MS 250
#endif

void blocking_sleep(int ms) {
    sleep_ms(ms);
}

// Perform initialisation
int onboard_led_init(void) {
#if defined(PICO_DEFAULT_LED_PIN)
    // A device like Pico that uses a GPIO for the LED will define PICO_DEFAULT_LED_PIN
    // so we can use normal GPIO functionality to turn the led on and off
    gpio_init(PICO_DEFAULT_LED_PIN);
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT);
    return PICO_OK;
#elif defined(CYW43_WL_GPIO_LED_PIN)
    // For Pico W devices we need to initialise the driver etc
    return cyw43_arch_init();
#endif
}

// Turn the led on or off
void onboard_led_set(bool led_on) {
#if defined(PICO_DEFAULT_LED_PIN)
    // Just set the GPIO on or off
    gpio_put(PICO_DEFAULT_LED_PIN, led_on);
#elif defined(CYW43_WL_GPIO_LED_PIN)
    // Ask the wifi "driver" to set the GPIO on or off
    cyw43_arch_gpio_put(CYW43_WL_GPIO_LED_PIN, led_on);
#endif
}

void onboard_led_assert_init() {
    int rc = onboard_led_init();
    hard_assert(rc == PICO_OK);
}

void main_loop_additions() {
    onboard_led_set(true);
    sleep_ms(LED_DELAY_MS);
    onboard_led_set(false);
    sleep_ms(LED_DELAY_MS);
}

intptr_t PassToSDKModule(intptr_t);

intptr_t use_swift_callback(intptr_t x) {
    int result = PassToSDKModule(x);
    return result;
}

void blink_set_number() {
    int count = use_swift_callback(3);
    for(int i = 0; i < count; i++) {
        onboard_led_set(true);
        sleep_ms(LED_DELAY_MS);
        onboard_led_set(false);
        sleep_ms(LED_DELAY_MS);
    }

}


