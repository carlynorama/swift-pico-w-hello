/// Implement `posix_memalign(3)`, which is required by the Swift runtime but is
/// not provided by the pico-sdk library which does not support C-99
//from search for posix_memalign using language Swift
// https://github.com/apple/swift-playdate-examples/blob/749dd8f518429168d03e754764afb334a80b527d/Sources/Playdate/Playdate.swift#L21
@_documentation(visibility: internal)
@_cdecl("posix_memalign")
public func posix_memalign(
  _ memptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
  _ alignment: Int,
  _ size: Int
) -> CInt {
  guard let allocation = malloc(Int(size + alignment - 1)) else {
    #if hasFeature(Embedded)
    fatalError()
    #else
    fatalError("Unable to handle memory request: Out of memory.")
    #endif
  }
  let misalignment = Int(bitPattern: allocation) % alignment
  #if hasFeature(Embedded)
  precondition(misalignment == 0)
  #else
  precondition(
    misalignment == 0,
    "Unable to handle requests for over-aligned memory.")
  #endif
  memptr.pointee = allocation
  return 0
}