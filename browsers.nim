
import std/os
import std/strutils
import std/winlean

proc prepare(s: string): string =
  if s.contains("://"):
    result = s
  else:
    result = "file://" & absolutePath(s)

when defined(windows):
  type c_enum = cint ## a type placeholder (any type can be used)
  {.push header:"<shlwapi.h>".}
  type
    ASSOCF{.importc.} = c_enum
    ASSOCKEY{.importc.} = c_enum
  let
    ASSOCF_NONE{.importc.}: ASSOCF
    ASSOCSTR_EXECUTABLE{.importc.}: ASSOCKEY
  {.pop.}
  type HRESULT{.importc.} = int32
  proc AssocQueryStringW(
    flags: ASSOCF, str: ASSOCKEY, pszAssoc, pszExtra, pszOut: WideCString, pcchOut: ptr DWORD
    ): HRESULT{.importc, dynlib:"shlwapi".}

  template assoc(assoc, extra, buffer, sizep): void =
    discard AssocQueryStringW(ASSOCF_NONE, ASSOCSTR_EXECUTABLE,
      assoc, extra, buffer, sizep)
    # if `buffer` is NULL, the discarded result is `S_FALSE`
    # else is `E_POINTER`
    #   if `pszOut` is too small to hold the entire string (not possible here)
    # else is `S_OK`
    # In short, no need to check the result

  proc getDefaultBrowser: WideCStringObj{.inline.} =
    let
      assoc = newWideCString"http"
      extra = newWideCString"open"
    var size: DWORD
    assoc(assoc, extra, nil, size.addr)
    result = newWideCString(size.int)
    assoc(assoc, extra, result, size.addr)
  var browser{.threadvar.}: WideCStringObj
else:
  var browser{.threadvar.}: string
    
proc openDefaultBrowserRaw(url: string) =
  ## passing `url` to the browser "AS IS", will never add `file://` prefix
  when defined(windows):
    if browser == default typeof browser: browser = getDefaultBrowser()
    let arg = newWideCString(url)
    discard shellExecuteW(0'i32, nil, browser, arg, nil, SW_SHOWNORMAL)
  elif defined(macosx):
    discard execShellCmd(osOpenCmd & " " & quoteShell(url))
  else:
    template op(nbrowser) = 
        # we use `startProcess` here because we don't want to block!
        discard startProcess(command = nbrowser, args = [url], options = {poUsePath})
    if browser != default typeof browser:
      op(browser)
      return
    template test(b) =
      try:
        op(b)
        browser = b
        return
      except OSError:
        discard
    let dotDesktop = quoteShell execProcess("xdg-mime query default text/html")
    let dBro = try: execProcess("gtk-open "&dotDesktop)
               except OSError: execProcess("gi launch "&dotDesktop)
    test(dBro)
    for b in getEnv("BROWSER").split(PathSep):
      test(b)


proc openDefaultBrowser*(url: string) =
  doAssert url.len > 0, "URL must not be empty string"
  openDefaultBrowserRaw prepare url

proc openDefaultBrowser* = openDefaultBrowserRaw "about:blank"

when isMainModule:
  if paramCount()>0:
    openDefaultBrowser paramStr 1
  else:
    openDefaultBrowser()
