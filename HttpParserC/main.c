//
//  main.c
//  HttpParserC
//
//  Created by Helge Heß on 06/06/16.
//
//

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include "timespec.h"

const char *loadTestDataIntoBuffer(const char *p) {
  FILE *fh = fopen(p, "rw");
  assert(fh != NULL);
  
  char *buf = malloc(16000);
  size_t rc = fread(buf, 1, 16000, fh);
  assert(rc > 100);
  buf[rc] = 0;
  fclose(fh);
  return buf;
}

int main(int argc, const char * argv[]) {
  const char *simpleGet1 = loadTestDataIntoBuffer("TestData/SimpleGET1.txt");
  // printf("Request:\n%s\n", simpleGet1);

  struct timespec startTS = ari_monotonic();
  
  printf("Hello, World!\n");

  struct timespec endTS = ari_monotonic();

  int diff = ari_timespec_ms(ari_timespec_diff(endTS, startTS));
  printf("time: %ims\n", diff);
  
  return 0;
}
