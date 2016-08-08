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

C Version - Release Build (2016-08-08):

    [0] time: 93ms
    [1] time: 93ms
    [2] time: 96ms
    [3] time: 95ms
    [4] time: 94ms
    -----
    Total: 471ms COUNT: 10002000

Swift 2.2 - Release Build, safety checks off (doesn't matter)

    [0] time: 890ms
    [1] time: 881ms
    [2] time: 880ms
    [3] time: 885ms
    [4] time: 882ms
    -----
    Total: 4418ms COUNT: 20 **WRONG** Closures are reset

Swift 3 Preview 4  (2016-08-08)

struct vtable:

    [0] time: 2021ms
    [1] time: 2017ms
    [2] time: 2027ms
    [3] time: 2020ms
    [4] time: 2021ms
    -----
    Total: 10106ms COUNT: 10002000

protocol with closures:

    [0] time: 3865ms
    [1] time: 3873ms
    [2] time: 3905ms
    [3] time: 3875ms
    [4] time: 3880ms
    -----
    Total: 19398ms COUNT: 20004000


#### Instruments Says

- lots of ARC killing perf
  - TODO: check with latest w/o closures

### struct-parser branch

- this is in `master` now

### lookup-tables branch

- this is in `master` now

### always-inline branch

- this is in `master` now
