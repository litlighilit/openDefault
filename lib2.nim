## declare all used types and function
{.warning[HoleEnumConv]:off.} # we know if it's safe. See `template `|`[E: ASSOCF](x, y: E): E = E(x.ord or y.ord)`
when not defined(windows):{.error:"this mod is Windows only!".}
const lib_ed = declared(os)
when not lib_ed: import std/os # as `'import' is only allowed at top level`
{.passL: "-l Shlwapi".}
type
    cenum = c_int
    DWORD = c_ulong
{.push header:"<shlwapi.h>", importc.}
type ASSOCF = enum
    ASSOCF_VERIFY                = 0x00000040.cenum
    ASSOCF_NOFIXUPS              = 0x00000100
    MY_CONBIN = 0x140 # a posue-do enum value that doesn't exist (so that L21 can be compiled)
type ASSOCSTR = enum
  ASSOCSTR_EXECUTABLE = 2.cenum
type HRESULT = enum
  S_OK = 0.cenum
proc AssocQueryStringA(
      flags: ASSOCF, str: ASSOCSTR,
      pszAssoc, pszExtra, pszOut: cstring, pcchOut: ptr[DWord]
    ): HRESULT
{.pop.}
template `|`[E: ASSOCF](x, y: E): E = E(x.ord or y.ord)
const ext = ".html".cstring

template assoc(buffer: cstring, sizep: ptr[DWord]): untyped =
  AssocQueryStringA(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, ext,
          nil, buffer, sizep)

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