//
//  main.swift
//  HttpParserSwift
//
//  Created by Helge Heß on 06/06/16.
//
//

import Foundation

func loadTestDataIntoBuffer(path p: String) -> UnsafePointer<CChar> {
  let fh = fopen(p, "rb")
  assert(fh != nil)
  
  let buf = UnsafeMutablePointer<UInt8>.alloc(16000)
  let rc = fread(buf, 1, 16000, fh)
  assert(rc > 100)
  buf[rc] = 0
  fclose(fh)
  return UnsafePointer<CChar>(buf)
}


let simpleGet1 = loadTestDataIntoBuffer(path: "TestData/SimpleGET1.txt")
// print("Request:\n\(String.fromCString(simpleGet1)!)\n")

let startTS = timespec.monotonic()

print("Hello, World!")

let endTS = timespec.monotonic()
let diff  = (endTS - startTS).milliseconds

print("time: \(diff)ms")
