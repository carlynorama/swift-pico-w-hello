


struct Button {
    let pin:UInt32

    init(pin p:UInt32, enablePullUp:Bool = true) {
        gpio_init(p);
        gpio_set_dir(p, false);
        if enablePullUp {
            gpio_pull_up(p);
        }
        self.pin = p
    }

    var isActive:Bool {
        !gpio_get(pin)
    }

    func read() -> Bool {
        gpio_get(pin)
    }
}




