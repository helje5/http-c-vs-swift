//
//  main.swift
//  HttpParserSwift
//
//  Created by Helge Heß on 06/06/16.
//
//

import Darwin

let warmupCount    = 100
let testCount      = 100000
let testIterations = 5

func loadTestDataIntoBuffer(path p: String) -> UnsafePointer<CChar> {
  let fh = fopen(p, "rb")
  assert(fh != nil)
  
  #if swift(>=3.0) // #swift3-inout
    let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: 16000)
  #else
    let buf = UnsafeMutablePointer<UInt8>.alloc(16000)
  #endif
  let rc = fread(buf, 1, 16000, fh)
  assert(rc > 100)
  buf[rc] = 0
  fclose(fh)
  return UnsafePointer<CChar>(buf)
}


let simpleGet1    = loadTestDataIntoBuffer(path: "TestData/SimpleGET1.txt")
let simpleGet1len = size_t(strlen(simpleGet1))
// print("Request:\n\(String.fromCString(simpleGet1)!)\n")


var count = 0 // to make sure that the optimizer doesn't kill the callbacks?
var parser = http_parser(type: .Request)


// direct vtable based imp

struct PerfSettingsCB : http_parser_settings {
  func onMessageBegin   (parser p : http_parser ) -> Int {
    count += 1; return 0
  }
  func onURL            (parser p : http_parser,
                         _ data: UnsafePointer<CChar>, _ len: size_t) -> Int
  {
    count += 1; return 0
  }
  func onStatus         (parser p : http_parser,
                         _ data: UnsafePointer<CChar>, _ len: size_t) -> Int
  {
    count += 1; return 0
  }
  func onHeaderField    (parser p : http_parser,
                         _ data: UnsafePointer<CChar>, _ len: size_t) -> Int
  {
    count += 1; return 0
  }
  func onHeaderValue    (parser p : http_parser,
                         _ data: UnsafePointer<CChar>, _ len: size_t) -> Int
  {
    count += 1; return 0
  }
  func onHeadersComplete(parser p : http_parser ) -> Int {
    count += 1; return 0
  }
  func onBody           (parser p : http_parser,
                         _ data: UnsafePointer<CChar>, _ len: size_t) -> Int
  {
    count += 1; return 0
  }
  func onMessageComplete(parser p : http_parser ) -> Int {
    count += 1; return 0
  }
}


// closure based imp

var ClosureSettings = http_parser_settings_cb()
ClosureSettings.onMessageBegin    { _ in count += 1; return 0 }
ClosureSettings.onHeadersComplete { _ in count += 1; return 0 }
ClosureSettings.onHeaderField     { _ in count += 1; return 0 }
ClosureSettings.onHeaderValue     { _ in count += 1; return 0 }
ClosureSettings.onBody            { _ in count += 1; return 0 }
ClosureSettings.onStatus          { _ in count += 1; return 0 }
ClosureSettings.onURL             { _ in count += 1; return 0 }
ClosureSettings.onMessageComplete { _ in count += 1; return 0 }


func runTest(withSettings settings: http_parser_settings) {
  // warm up
  print("Warming up ...")
  for _ in 0..<warmupCount {
    assert(parser.error == .OK)
    let nb = parser.execute(settings, simpleGet1, simpleGet1len)
    assert(nb == simpleGet1len)
    _ = parser.execute(settings, nil, 0) // EOF
    parser.reset()
  }
  print("done.")


  var totalMS = 0
  for i in 0..<testIterations {
    let startTS = timespec.monotonic()

    for _ in 0..<testCount {
      assert(parser.error == .OK)
      let nb = parser.execute(settings, simpleGet1, simpleGet1len)
      assert(nb == simpleGet1len)
      _ = parser.execute(settings, nil, 0) // EOF
      parser.reset(type: .Request)
    }

    let endTS = timespec.monotonic()
    let diff  = (endTS - startTS).milliseconds
    totalMS += diff
    
    print("[\(i)] time: \(diff)ms")
  }
  print("-----\nTotal: \(totalMS)ms COUNT: \(count)")
}

runTest(withSettings: PerfSettingsCB())
runTest(withSettings: ClosureSettings)
