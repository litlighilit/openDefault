# openDefaultBrowser in Windows
_interesting skill showcase, just for fun_

## desc
As an answser to `how to invoke the browser by programming`.  
Some is translated from C++'s code (see `cpp/`)

## about `otherImpl/`

In `otherImpl` subdir, there are server `lib*.nim`,
which are different versions of the almostly same logic.
The only difference lies in how `AssocQueryString` is imported. 

In addition, there is [another version](https://gist.github.com/litlighilit/8c19c4cb2dcec801ab424889684c4e69) using std/registery
 instead of `AssocQueryString`

For details, see `otherImpl/README.md`
