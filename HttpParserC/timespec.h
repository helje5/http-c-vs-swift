//
//  timespec.h
//  HttpSwiftVsC
//
//  Created by Helge Heß on 06/06/16.
//
//

#ifndef timespec_h
#define timespec_h

#include <sys/kernel.h>
#include <mach/mach_types.h>
#include <mach/mach_host.h>
#include <mach/mach_port.h>
#include <mach/clock.h>

static struct timespec ari_monotonic() {
  clock_serv_t    cclock;
  mach_timespec_t mts;
  
  host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
  clock_get_time(cclock, &mts);
  mach_port_deallocate(mach_task_self_, cclock);
  
  // probably the same, but well.
  struct timespec ts;
  ts.tv_nsec = mts.tv_nsec;
  ts.tv_sec  = mts.tv_sec;
  return ts;
}

static int ari_timespec_ms(struct timespec ts) {
  return (int)((ts.tv_sec * 1000) + (ts.tv_nsec / 1000000));
  
}

static struct timespec ari_timespec_diff
  (struct timespec left, struct timespec right)
{
  struct timespec result;
  
  if ((left.tv_nsec - right.tv_nsec) < 0) {
    result.tv_sec  = left.tv_sec - right.tv_sec - 1;
    result.tv_nsec = 1000000000 + left.tv_nsec - right.tv_nsec;
  }
  else {
    result.tv_sec  = left.tv_sec  - right.tv_sec;
    result.tv_nsec = left.tv_nsec - right.tv_nsec;
  }
  
  return result;
}


#endif /* timespec_h */
