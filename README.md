# openDefault


## brief
  open `uri` with external application configured to open `scheme`

  or

  open your default browser with given URL.



**Progress**:

 - Not tested under Mac OS X

**Feature**:

 - implemented for Linux, Windows and Mac OS X
 - support JavaScript backend for `openDefaultBrowser` (require [open](https://www.npmjs.com/package/open) package)


## history
There once was an intend to implement
opening "about:blank" in Nim's stdlib `browsers` (via `openDefaultBrowser()` API).

but finally it was found to require much code to implement.
Anyway,
this repo has implemented that.

Also, as `openDefaultBrowser()` in `std/browsers` is deprecated and to be removed,
I think it's better to make `openDefaultBrowser()` in this repo open inital page instead of blank page.

After all, who ever wants a blank page.

In addtion, it can be 
as an answser to `how to invoke the browser by programming`.  