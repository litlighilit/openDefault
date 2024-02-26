# openDefaultBrowser in Windows

There once was an intend to implement
opening "about:blank" in Nim's stdlib `browsers` (via `openDefaultBrowser()` API).

but finally it was found hard to implement (at least not as easily as thought).

Anyway,
this repo tries to implement that.

**Progress**:

 - Not tested under Mac OS X
 - implemented for Linux and Windows

## desc
As an answser to `how to invoke the browser by programming`.  
Some is translated from C++'s code (see `cpp/`)

## about `cpp/`
C/C++ version of openDefaultBrowser, 
created for testing under Windows

## about `otherImpl/`

_interesting skill showcase, just for fun_

In `otherImpl` subdir, there are server `lib*.nim`,
which are different versions of the almostly same logic.
The only difference lies in how `AssocQueryString` is imported. 

In addition, there is [another version](https://gist.github.com/litlighilit/8c19c4cb2dcec801ab424889684c4e69) using std/registery
 instead of `AssocQueryString`

For details, see `otherImpl/README.md`
