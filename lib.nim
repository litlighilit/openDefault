## use dynlib and declare used types and functions
# As `proc openDefaultBrowser()`'s body (included) (require os, dynlib)
# but can also run as a main module
when not defined(windows): {.error: "this mod is Windows only!".}
const lib_ed = declared(os)
when not lib_ed: import std/[dynlib, os] # as `'import' is only allowed at top level`

const ext = ".html"
type
  DWord = c_ulong
  cenum = c_int
  HRESULT = c_long

const # see shlwapi.h
  ASSOCF_NOFIXUPS = 256
  ASSOCF_VERIFY = 64
  ASSOCSTR_EXECUTABLE = 2
  
#template addr[T](x: T): ptr T = x.unsafeAddr # not used
template cstr(p: pointer): cstring = cast[cstring](p)

let lib = loadLib("shlwapi.dll")
when lib_ed:
  defer: unloadLib(lib)
template lsym(s): pointer = lib.checkedSymAddr(s)
template loadsym(sym: untyped) =
  let sym = lsym(astToStr(sym))

loadsym(AssocQueryStringA)
if AssocQueryStringA == nil:
  echo "could not find symbol: ", "AssocQueryStringA"
  unloadLib(lib)
  quit(-1)
type
  FAssoc = proc (
      flags, str: cenum,
      pszAssoc, pszExtra, pszOut: cstring, pcchOut: ptr[DWord]
    ): HRESULT {.gcsafe, stdcall.}

template assocQueryString(
    flags, str: int, pszAssoc: string,
    pszExtra, pszOut: cstring, pcchOut: ptr[DWord]
): untyped =
    cast[FAssoc](AssocQueryStringA)(
        flags.cenum, str.cenum, pszAssoc.cstring, pszExtra.cstring,
        pszOut, pcchOut
    )
template `|`(x, y: int): int = x or y
template assoc(buffer: cstring, sizep: ptr[DWord]): untyped =
  assocQueryString(ASSOCF_NOFIXUPS|ASSOCF_VERIFY, ASSOCSTR_EXECUTABLE, ext,
          nil, buffer, sizep)

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

when not lib_ed: unloadLib(lib)
