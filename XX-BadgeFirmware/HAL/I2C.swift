    
// https://github.com/raspberrypi/pico-examples/blob/master/i2c/bus_scan/bus_scan.c

//TODO: Removed ability to engage with the default. Decide whether to put one back
// that maybe too specific to a hardware to put in the protocol long term? 
//

struct I2C {
    //TODO: THis needs to be a protocol? An enum needs to be in the protocol? It has to be
    //able to be per hardware defined. 
    public enum Instance {
        case i2c0
        case i2c1
    }

    let instance:Instance

    //after init these will actually be in C struct.
    //TODO: make these dynamic vars and peak in the underlying C 
    let dataPin:Int32
    let clockPin:Int32
    let baudRate:Int32

    init(_ i:Instance, dataPin SDA:Int32, clockPin SCL:Int32, baudRate BAUD:Int32 = 400 * 1000) {
        //TODO make conditional init. 
        let _ = I2C.setupInstance(i, dataPin:SDA, clockPin:SCL, baudRate:BAUD)
        I2C.activeBusses.append(i)

        self.instance = i
        self.dataPin = SDA
        self.clockPin = SCL
        self.baudRate = BAUD
    }

    func scan() -> [Int32] {
        I2C.scan(instance)
    }

    func scan(for address:Int32) -> Bool {
        I2C.scan(instance, for:address)
    }



}

extension I2C {
    
    //TODO: Enable a default init
    // init() {
    //     //TODO, get the default information out
    //     i2c_setup_default()
    //     self.instance = .i2c0 //TODO: confirm
    //     self.dataPin = 4
    //     self.clockPin = 5
    //     self.baudRate = 400 * 1000
    // }

}

extension I2C {

    //This is determined per project. Would it be better to be in the project? 
    static var activeBusses:[Instance] = []

    static func isReserved(_ addr:Int32) -> Bool {
        return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
    }

    static func scan(_ instance:Instance) -> [Int32] {
        let checking_func:(Int32) -> Int32 = switch instance {
                case .i2c0 : i2c_i2c0_address_check
                case .i2c1 : i2c_i2c1_address_check
        }

        // var validAddresses:[Int] = []
        // for address in (0..<(1 << 7)) {
        //     if !I2C.isReserved(Int32(address)) {
        //         let result = checking_func(Int32(address))
        //         USBSerial.send("\(result)")
        //         if result > -1  {
        //             validAddresses.append(address)
        //         }
        //     }
 
        // }
        // return validAddresses

        //TODO switch to this once verify scan works. 
            // //cool, didn't think to do this in Swift before. 
            // //maxAddress is top of the 7bit address space.
            var validAddresses:[Int32] = (0..<(1 << 7)).filter { a in
                !I2C.isReserved(Int32(a)) && checking_func(Int32(a)) > -1
            }
            return validAddresses

    }

    static func scan(_ instance:Instance, for address:Int32) -> Bool {
        let checking_func:(Int32) -> Int32 = switch instance {
                case .i2c0 : i2c_i2c0_address_check
                case .i2c1 : i2c_i2c1_address_check
        }
        
        
        let result = checking_func(Int32(address))
        return result == 0
    }


    //default 400kHz
    static func setupInstance(_ instance:Instance, 
                                dataPin SDA:Int32, 
                                clockPin SCL:Int32, 
                                baudRate BAUD:Int32 = 400 * 1000
    ) -> Bool {
        let setup_func:(Int32, Int32, Int32) -> Int32 = switch instance {
                case .i2c0 : i2c_setup_i2c0
                case .i2c1 : i2c_setup_i2c1
        }

        let result = setup_func(SDA, SCL, BAUD)
        if result == 0 {
            return true
        }
        return false

    }

}
