//
//  main.c
//  HttpParserC
//
//  Created by Helge Heß on 06/06/16.
//
//

#include <stdio.h>
#include "timespec.h"

int main(int argc, const char * argv[]) {

  struct timespec startTS = ari_monotonic();
  
  printf("Hello, World!\n");

  struct timespec endTS = ari_monotonic();

  int diff = ari_timespec_ms(ari_timespec_diff(endTS, startTS));
  printf("time: %ims\n", diff);
  
  return 0;
}
