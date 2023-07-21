## use importcpp's `#` represent
when not defined(cpp): {.error: "use `nim cpp` instead of `nim c` as a feature of `importcpp` is used".}
when not defined(windows):{.error:"this mod is Windows only!".}
const lib_ed = declared(os)
when not lib_ed: import std/os # as `'import' is only allowed at top level`
{.passL: "-l Shlwapi".}
type
    cenum = c_int
    DWORD = uint32

type HRESULT{.header:"<shlwapi.h>", importc.} = enum
  S_OK = 0.int32

const ext = ".html"
const assoc_c = "AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE,\"" & ext & "\", NULL, #, #)"
func assoc(
      pszOut: cstring, pcchOut: ptr[DWord]
    ): HRESULT{.importcpp:assoc_c, cdecl.}

template cstr(p: pointer): cstring = cast[cstring](p)
# almost the same as lib.nim L52
proc getDefaultBrowser(buf: var cstring): int =
  var size: DWord = 0
  var hr = assoc(nil, size.addr)
  result = size.int
  buf = alloc(result).cstr
  hr = assoc(buf, size.addr)
  if size == 0:
    stderr.write "can't exec assco\n"
    quit(-1)

include ./lib_common
