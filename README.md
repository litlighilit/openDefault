# openDefaultBrowser

There once was an intend to implement
opening "about:blank" in Nim's stdlib `browsers` (via `openDefaultBrowser()` API).

but finally it was found hard to implement (at least not as easily as thought).

Anyway,
this repo tries to implement that.

**Progress**:

 - Not tested under Mac OS X

**Feature**:

 - implemented for Linux, Windows and Mac OS X
 - support JavaScript backend (require [open](https://www.npmjs.com/package/open) package)

## origin from ...
As an answser to `how to invoke the browser by programming`.  

