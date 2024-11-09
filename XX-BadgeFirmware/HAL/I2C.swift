    
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
        

        self.instance = i
        self.dataPin = SDA
        self.clockPin = SCL
        self.baudRate = BAUD

        I2C.activeBusses.append(self)
    }

    func scan() -> [UInt8] {
        I2C.scan(instance)
    }

    func scan(for address:UInt8) -> Bool {
        I2C.scan(instance, for:address)
    }



    //send a single
    func write(_ value:UInt8, at register:UInt8, for address:UInt8) {
        //uint8_t addr, const uint8_t *src, int len, bool nostop
        let sending_func:(UInt8, UnsafePointer<UInt8>, Int32, Bool) -> Int32 = switch instance {
                case .i2c0 : i2c_write_i2c0
                case .i2c1 : i2c_write_i2c1
        }
        //int i2c_write_i2c0(uint8_t addr, const uint8_t *src, size_t len, bool nostop);
        let addr = UInt8(address)
        var writeBuffer:[UInt8] = [register,value]
        let len:Int32 = Int32(1 + MemoryLayout.size(ofValue: value))
        //should this session keep control of the bus when done with this write.
        //(are you going to immediately read or write something else)
        let nostop = false 
        let _ = sending_func(addr, &writeBuffer, len, nostop)
    }

    //TODO: Handle empty array.
    func writeSequence(_ value:[(UInt8,UInt8)], for address:UInt8) {
        let sending_func:(UInt8, UnsafePointer<UInt8>, Int32, Bool) -> Int32 = switch instance {
                case .i2c0 : i2c_write_i2c0
                case .i2c1 : i2c_write_i2c1
        }
        let len = Int32(1 + MemoryLayout.size(ofValue: value[0].0))
        //int i2c_write_i2c0(uint8_t addr, const uint8_t *src, size_t len, bool nostop);
        for i in (0..<(value.count)) {
            let (value, register) = value[i]
            var writeBuffer:[UInt8] = [register,value]
            let _ = sending_func(address, &writeBuffer, len, false)
        }
    }

    //won't need this typically, a read without a pre-write
    private func read(from addr:UInt8, at register:UInt8, length:Int32) -> [UInt8] {
        let reading_func:(UInt8, UnsafeMutablePointer<UInt8>?, Int32, Bool) -> Int32 = switch instance {
            case .i2c0 : i2c_read_i2c0
            case .i2c1 : i2c_read_i2c1
        }

        //int i2c_read_i2c0(uint8_t addr, uint8_t *dst, int len, bool nostop);
        var buffer = Array<UInt8>(repeating: 0, count: Int(length))
        
        //function returns status code in theory.
        let _ = buffer.withContiguousMutableStorageIfAvailable { dest in
            reading_func(addr, dest.baseAddress, length, false)
        } 

        return buffer
    }

    
    func readValue(from addr:UInt8, at register:UInt8, length:Int32) -> [UInt8] {
        let reading_func:(UInt8, UnsafeMutablePointer<UInt8>?, Int32, Bool) -> Int32 = switch instance {
            case .i2c0 : i2c_read_i2c0
            case .i2c1 : i2c_read_i2c1
        }

        let sending_func:(UInt8, UnsafePointer<UInt8>, Int32, Bool) -> Int32 = switch instance {
                case .i2c0 : i2c_write_i2c0
                case .i2c1 : i2c_write_i2c1
        }

        //int i2c_read_i2c0(uint8_t addr, uint8_t *dst, int len, bool nostop);
        var readBuffer = Array<UInt8>(repeating: 0, count: Int(length))
        var writeBuffer:[UInt8] = [register]
        let _ = sending_func(addr, &writeBuffer, length, false) //TODO: when set to true fails?
        //function returns status code in theory.
        let _ = readBuffer.withContiguousMutableStorageIfAvailable { dest in
            reading_func(addr, dest.baseAddress, length, false)
        } 

        return readBuffer
    }

    //Currently not working, TODO, test with other i2c device. 
    func readValue2(from addr:UInt8, at register:UInt8, length:Int32) -> [UInt8] {
        let write_reading_func:(UInt8, UnsafePointer<UInt8>, Int32, UnsafeMutablePointer<UInt8>?, Int32) -> Int32 = switch instance {
            case .i2c0 : i2c_write_read_i2c0
            case .i2c1 : i2c_write_read_i2c1
        }

        //int i2c_read_i2c0(uint8_t addr, uint8_t *dst, int len, bool nostop);
        var readBuffer = Array<UInt8>(repeating: 0, count: Int(length))
        var writeBuffer:[UInt8] = [register]

        let _ = readBuffer.withContiguousMutableStorageIfAvailable { dest in
            write_reading_func(addr, &writeBuffer, 1, dest.baseAddress, length)
        } 

        return readBuffer
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
    static var activeBusses:[I2C] = []

    static func isReserved(_ addr:UInt8) -> Bool {
        return (addr & 0x78) == 0 || (addr & 0x78) == 0x78;
    }

    static func scan(_ instance:Instance) -> [UInt8] {
        let checking_func:(UInt8) -> Int32 = switch instance {
                case .i2c0 : i2c_i2c0_address_check
                case .i2c1 : i2c_i2c1_address_check
        }
        //maxAddress is 128, or 10000000
        return (0..<(1 << 7)).filter { a in
            !I2C.isReserved(UInt8(a)) && checking_func(UInt8(a)) > -1
        }
    }

    static func scan(_ instance:Instance, for address:UInt8) -> Bool {
        let checking_func:(UInt8) -> Int32 = switch instance {
                case .i2c0 : i2c_i2c0_address_check
                case .i2c1 : i2c_i2c1_address_check
        }
        
        
        let result = checking_func(address)
        return result > -1
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
