Performance Comparison of Swift http-parser port
================================================

Source Repository is:

  git@github.com:helje5/HTTPParser.git

Swift port was branched of C http-parser Version 2.6.0, git hash:

  bee4817ebea0eaa592143c7825f5c96f040c84e4

Swift port version this started from:

  d3912dd40b4c2db9d23932649404e6e58f7ba013


### Port Specific Notes

The port has NOT been optimized for speed at all.

- macros have been replaced with func's
  - so the compiler has to be smart to inline them
  - the C macros have been accessing local state, to simulate that
    I used nested functions
- the big goto loop has been replaced with a step function,
- there are a few dispatch tables which are converted straight to Swift arrays,
  such are range-checked etc
- callbacks are done using regular Swift closures

### Ideas to get the Swift faster

Instruments says that almost all the time is lost in ARC.

- the dispatch tables are stored in global-let's, does this always
  have a dispatch_once overhead?
  - the parser might need to grab a copy of the pointer on startup
    or execute,
    but the macros would need to move into the parser.
- the callback closure invocations are pretty slow, we may be able
  to convert such to `convention(c)` closures
  - Update: this does not seem to be possible at the moment as Swift structs
            can't be marked as `convention(c)` (hence the callbacks can't be
            either)
    - there is an unofficial `convention(thin)`, but that is too easy to crash
    - we may be forced to switch to a delegate protocol to get appropriate
      performance
- would unwrapping the nested funcs have any perf advantage?

## RESULTS

### 2016-06-07 aka lazy-port-1

MacPro 3.7 GHz Quad-Core Intel Xeon E5

C Version - Release Build:

    [0] time: 97ms
    [1] time: 97ms
    [2] time: 101ms
    [3] time: 97ms
    [4] time: 98ms
    -----
    Total: 490ms COUNT: 10002000

Swift 2.2 - Release Build, safety checks off (doesn't matter)

    [0] time: 890ms
    [1] time: 881ms
    [2] time: 880ms
    [3] time: 885ms
    [4] time: 882ms
    -----
    Total: 4418ms COUNT: 20 **WRONG** Closures are reset

Swift 3 2016-05-31

    [0] time: 910ms
    [1] time: 897ms
    [2] time: 900ms
    [3] time: 905ms
    [4] time: 904ms
    -----
    Total: 4516ms COUNT: 20 **WRONG** Closures are reset

#### Instruments Says

- lots of ARC killing perf

### struct-parser branch

In this the parser object is a struct, hence no dynamic dispatch on parser
funcs.

Swift 2.2

    [0] time: 886ms
    [1] time: 880ms
    [2] time: 879ms
    [3] time: 876ms
    [4] time: 889ms
    -----
    Total: 4410ms COUNT: 20 **WRONG** Closures are reset

Improv not measurable, but then we allocate the parser object just once.

### lookup-tables branch

In this the Swift-array lookup tables are replaced with UnsafePointer<T> to
avoid runtime checks.

Swift 2.2

    [0] time: 853ms
    [1] time: 850ms
    [2] time: 847ms
    [3] time: 850ms
    [4] time: 851ms
    -----
    Total: 4251ms COUNT: 20 **WRONG** Closures are reset

A little better, but not much.

### always-inline branch

Make funcs which used to be macros in C always-inline. This gives some
break-through.

    [0] time: 289ms
    [1] time: 288ms
    [2] time: 286ms
    [3] time: 285ms
    [4] time: 285ms
    -----
    Total: 1433ms COUNT: 10002000

Swift 1433ms vs C 490ms
