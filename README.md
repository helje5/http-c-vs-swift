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
    Total: 4418ms COUNT: 20

Swift 3 2016-05-31

    [0] time: 910ms
    [1] time: 897ms
    [2] time: 900ms
    [3] time: 905ms
    [4] time: 904ms
    -----
    Total: 4516ms COUNT: 20

#### Instruments Says

- lots of ARC killing perf

### struct-parser branch

Swift 2.2

    [0] time: 886ms
    [1] time: 880ms
    [2] time: 879ms
    [3] time: 876ms
    [4] time: 889ms
    -----
    Total: 4410ms COUNT: 20

Improv not measurable, but then we allocate the parser object just once.

