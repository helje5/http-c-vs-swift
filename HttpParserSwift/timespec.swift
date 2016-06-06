//
//  timespec.swift
//  HttpSwiftVsC
//
//  Created by Helge Heß on 06/06/16.
//
//

import Darwin

public extension timespec {
  
  public init(_ mts: mach_timespec_t) {
    tv_sec  = __darwin_time_t(mts.tv_sec)
    tv_nsec = Int(mts.tv_nsec)
  }
  
  public static func monotonic() -> timespec {
    var cclock = clock_serv_t()
    var mts    = mach_timespec_t()
    
    host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
    clock_get_time(cclock, &mts);
    mach_port_deallocate(mach_task_self_, cclock);
    
    return timespec(mts)
  }
}

public extension timespec {
  
  public var seconds : Int {
    // TBD: rounding on tv_nsec?
    return tv_sec
  }
  
  public var milliseconds : Int {
    return (tv_sec * 1000) + (tv_nsec / 1000000)
  }
  
}

public func -(left: timespec, right: timespec) -> timespec {
  var result = timespec()
  
  if (left.tv_nsec - right.tv_nsec) < 0 {
    result.tv_sec  = left.tv_sec - right.tv_sec - 1
    result.tv_nsec = 1000000000 + left.tv_nsec - right.tv_nsec
  }
  else {
    result.tv_sec  = left.tv_sec  - right.tv_sec
    result.tv_nsec = left.tv_nsec - right.tv_nsec
  }
  
  return result
}

extension timespec: CustomStringConvertible {
  public var description : String {
    switch ( tv_sec, tv_nsec ) {
    case ( 0, 0 ): return "timespec()"
    case ( _, 0 ): return "timespec(\(tv_sec)s)"
    case ( 0, _ ): return "timespec(\(tv_nsec)ns)"
    default:       return "timespec(\(tv_sec)s, \(tv_nsec)ns)"
    }
  }
}
