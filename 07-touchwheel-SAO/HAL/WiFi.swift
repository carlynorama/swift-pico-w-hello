struct WiFi {
    static func confirm() -> Bool {
        if cyw43_arch_init() != 0 {
            return false
        }
        return true
    }
}