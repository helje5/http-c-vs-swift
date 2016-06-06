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
#include "http_parser.h"

static const int warmupCount    = 100;
static const int testCount      = 100000;
static const int testIterations = 5;

static const char *loadTestDataIntoBuffer(const char *p) {
  FILE *fh = fopen(p, "rw");
  assert(fh != NULL);
  
  char *buf = malloc(16000);
  size_t rc = fread(buf, 1, 16000, fh);
  assert(rc > 100);
  buf[rc] = 0;
  fclose(fh);
  return buf;
}

static int count = 0;

static int on_header_field(http_parser *p, const char *at, size_t length) {
  count++;
  return 0;
}
static int on_header_value(http_parser *p, const char *at, size_t length) {
  count++;
  return 0;
}
static int on_body(http_parser *p, const char *at, size_t length) {
  count++;
  return 0;
}
static int on_status(http_parser *p, const char *at, size_t length) {
  count++;
  return 0;
}
static int on_url(http_parser *p, const char *at, size_t length) {
  count++;
  return 0;
}

static int on_message_begin   (http_parser *p) { count++; return 0; }
static int on_headers_complete(http_parser *p) { count++; return 0; }
static int on_message_complete(http_parser *p) { count++; return 0; }

int main(int argc, const char * argv[]) {
  const char *simpleGet1 = loadTestDataIntoBuffer("TestData/SimpleGET1.txt");
  const size_t simpleGet1len = strlen(simpleGet1);
  // printf("Request:\n%s\n", simpleGet1);
  
  
  http_parser parser;
  http_parser_init(&parser, HTTP_REQUEST);
  
  http_parser_settings parserOn;
  memset(&parserOn, 0, sizeof(parserOn));
  parserOn.on_message_begin    = on_message_begin;
  parserOn.on_headers_complete = on_headers_complete;
  parserOn.on_header_field     = on_header_field;
  parserOn.on_header_value     = on_header_value;
  parserOn.on_body             = on_body;
  parserOn.on_status           = on_status;
  parserOn.on_url              = on_url;
  parserOn.on_message_complete = on_message_complete;
  
  // warm up
  puts("Warming up ...");
  for (int i = 0; i < warmupCount; i++) {
    assert(HTTP_PARSER_ERRNO(&parser) == HPE_OK);
    size_t nb = http_parser_execute(&parser, &parserOn,
                                    simpleGet1, simpleGet1len);
    assert(nb == simpleGet1len);
    http_parser_execute(&parser, &parserOn, NULL, 0); // EOF
    http_parser_init(&parser, HTTP_REQUEST);
  }
  puts("done.");
  
  int totalMS = 0;

  for (int i = 0; i < testIterations; i++) {
    struct timespec startTS = ari_monotonic();
    
    for (int j = 0; j < testCount; j++) {
      assert(HTTP_PARSER_ERRNO(&parser) == HPE_OK);
      size_t nb = http_parser_execute(&parser, &parserOn,
                                      simpleGet1, simpleGet1len);
      assert(nb == simpleGet1len);
      http_parser_execute(&parser, &parserOn, NULL, 0); // EOF
      http_parser_init(&parser, HTTP_REQUEST);
    }

    struct timespec endTS = ari_monotonic();
    int diff = ari_timespec_ms(ari_timespec_diff(endTS, startTS));
    totalMS += diff;
    
    printf("[%i] time: %ims\n", i, diff);
  }
  printf("-----\nTotal: %ims COUNT: %i\n", totalMS, count);
  
  return 0;
}
