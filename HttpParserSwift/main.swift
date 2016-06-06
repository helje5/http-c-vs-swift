//
//  main.swift
//  HttpParserSwift
//
//  Created by Helge Heß on 06/06/16.
//
//

import Foundation


let startTS = timespec.monotonic()

print("Hello, World!")

let endTS = timespec.monotonic()
let diff  = (endTS - startTS).milliseconds

print("time: \(diff)ms")
