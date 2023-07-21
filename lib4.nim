## use emit
when not defined(windows):{.error:"this mod is Windows only!".}

{.passL: "-l Shlwapi".}
type DWORD = c_ulong
# {.emit: "/*INCLUDESECTION*/\n#include<shlwapi.h>".} # when included, /*INCLUDESECTION*/ is no use, as the `emit` is not top-level
const inc_header = "-include shlwapi.h"

# `local_passc` will, when included, make nim complain "Error: unhandled exception: pragmas.nim(1097, 16) `sym != nil and sym.kind == skModule`  [AssertionDefect]"
{.passc: inc_header.}
const ext = ".html"
func assoc(
      pszOut: cstring, pcchOut: ptr[DWord]
    ) = 
      # each of three followings is ok
      # let cext{.used.} = ext.cstring;{.emit: "AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, `cext`, NULL, `pszOut`, `pcchOut`);".}
      # {.emit: [static(fmt"""AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, "{ext}", NULL,""") , pszOut, "," ,  pcchOut, ");"].}
      {.emit: ["AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, \""&ext&"\", NULL, " , pszOut, ", " ,  pcchOut, ");"].}

template cstr(p: pointer): cstring = cast[cstring](p)
proc getDefaultBrowser(buf: var cstring): int =
  var size: DWord = 0
  assoc(nil, size.addr)
  result = size.int
  buf = alloc(result).cstr
  assoc(buf, size.addr)
  if size == 0:
    stderr.write "can't exec assco\n"
    quit(-1)

include ./lib_common