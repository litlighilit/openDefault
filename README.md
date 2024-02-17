# openDefaultBrowser in Windows
_interesting skill showcase, just for fun_

## desc
As an answser to `how to invoke the browser by programming`.  
Some is translated from C++'s code (see `cpp/`)

## struction
there are three version of main module:

- dynlib_openDefaultBrowser.nim (include lib1.nim, which is the only explicitly requiring `std/dynlib`)
- openDefaultBrowser.nim (include lib2/3/4.nim, you can change the source to switch) then one more mature version is <https://gist.github.com/litlighilit/11910c81587d60e840930cd49a90ffd2>
- Another using std/registery:
https://gist.github.com/litlighilit/8c19c4cb2dcec801ab424889684c4e69

### note
In `lib_common`, which is shared by lib`n`.nim, the `url` is hard-coded,  
while it's easy to change this to translate it as a parameter instead

## shown skills
1. lib`n`.nim (n is 1,2,...) show different ways to invoke c-lib's function.  
  For details, see their module document as well as source codes
2. each libn.nim can either be a lib or a executable-module, which is implemented by `when` and `declared` (`defined` can also be helpful)
