
import std/strutils
import std/osproc
import std/os
import std/strtabs

when defined(windows):
  import std/winlean

const SchemeSep = ':'
proc fetchScheme(url: string): string = url.split(SchemeSep, 1)[0]

type DefaultNotFoundError = object of ValueError ## thrown when:
  ## 1. maybe scheme is invalid
  ## 2. maybe the implementation is not round enough to find the default

template raiseDefNErr(msg="can't find default app") =
  raise newException(DefaultNotFoundError, msg)



proc prepare(s: string): string =
  if s.contains("://"):
    result = s
  else:
    result = "file://" & absolutePath(s)

proc mapScheme(scheme: string): string =
  if scheme == "about": "http" else: scheme

when defined(js):
  proc openDefault*(url, scheme: string){.
    warn: "`scheme` is ignored when on JS target".}
    # put warn here to make `openDefaultBrowser` un-warned
  proc openDefaultRaw(url, scheme: string) =
    when defined(nodejs):
      const args = "{app:{name: m.apps.browser}}"
      {.emit: ["import(\"open\").then((m)=>m.default(", url.cstring,
        ",", args, "));" ].}
    else:
      {.emit: ["window.location.assign(", url.cstring, ");"].}
else:
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

    proc getDefault(scheme: string): string {.inline.} =
      let
        assoc = newWideCString scheme
        extra = newWideCString"open"
      var size: DWORD
      assoc(assoc, extra, nil, size.addr)
      if size == size.typeof.default: raiseDefNErr()
      var cstr = newWideCString(size.int)
      assoc(assoc, extra, cstr, size.addr)
      result = $cstr
  else:
    proc strip1NL(s: var string): bool =
      ## returns whether s.len != 0 and s!="\n"
      let len1 = s.len-1
      if len1==-1 : return
      if s[len1]=='\n':
        s.setlen len1 
        if s.len == 0: return
      return true
    template cleanOrRaise(result) =
      if strip1NL result:
        return quoteShell result
      else: raiseDefNErr()
      
    when defined(macosx):
      proc getDefault(scheme: string): string{.inline.} =
        result = execProcess(
            "perl -MMac::InternetConfig" &
              " -le 'print +(GetICHelper \""&scheme&"\")[1]')",
              env = %{"VERSIONER_PERL_PREFER_32_BIT":"1"})
        cleanOrRaise result
    else:
      const DesktopLaunchers = [
          "gio launch $# $#",
          "gtk-launch $# $#"
        ]
      proc searchDesktopFile(fn: string): string =
        # translated from xdg-open `open_generic_xdg_mime()`
        template checkInDir(dir) =
          let pth = dir / fn
          if fileExists pth: return pth
        template checkInEnv(env) =
          if existsEnv env:
            let dirs = getEnv env 
            for dir in dirs.split PathSep: checkInDir dir
        checkInEnv "XDG_DATA_HOME"
        checkInDir "~/.local/share/applications".expandTilde
        checlInEnv "XDG_DATA_DIRS"
        for dir in [
          "/usr/local/share/applications",
          "/usr/share/applications"
        ]: checkInDir dir
      proc getDefault(scheme: string): string{.inline.} =
        var desktopFn = execProcess("xdg-mime query default x-scheme-handler/" & scheme)
        if not strip1NL desktopFn: return
        result = searchDesktopFile desktopFn
        cleanOrRaise result

  var cachedPath = newStringTable() ## 
  ## Under Windows, the full path of default browser; (not quoted)
  ## Under Linux, the desktop file path(quoted via `quoteShell`);
  ## Under Mac OS X, the application identifier of default browser
  ##  (quoted via `quoteShell`)
    
  proc cachedGetDefault(scheme: string): string =
    const Em = ""
    result = cachedPath.getOrDefault(scheme, Em)
    if result == Em:
      result = getDefault scheme
      cachedPath[scheme] = result
  proc openDefaultRaw(url: string, scheme: string) =
    ## passing `url` to the browser "AS IS", will never add `file://` prefix
    ## passing scheme "AS IS", too (e.g. can't be "about")
    when defined(windows):
      let path = cachedGetDefault scheme
      #discard shellExecuteW(0'i32, nil, path, arg, nil, SW_SHOWNORMAL)
      discard startProcess(command=path, args=[url],
        options={poUsePath, poStdErrToStdOut})
      return
    elif defined(macosx):
      let path = cachedGetDefault scheme
      discard execShellCmd("open -a " & path & ' ' & url)
      return
    else:
      template tryDo(action, err=OSError) =
        ## prevent exception propagation
        try:
          action
          return
        except err: discard
      
      var path: string # desktop file path
      tryDo(err=DefaultNotFoundError): path = cachedGetDefault scheme

      let aUrl = quoteShell url
      for laun in DesktopLaunchers:
        tryDo:
          discard startProcess(laun % [path, aUrl],
            options={poUsePath, poEvalCommand})
          cachedPath[scheme] = aPth
      if scheme == "http":
        for b in getEnv("BROWSER").split(PathSep):
          tryDo:
            discard startProcess(command = b, args = [url],
              options = {poUsePath})
      raiseDefNErr()


proc openDefault*(uri, scheme: string) =
  openDefaultRaw(uri, mapScheme scheme)
proc openDefault*(uri: string) =
  ## `uri` can not be empty and must start with a scheme
  doAssert uri.len > 0, "URI must not be empty string"
  let scheme = fetchScheme uri
  doAssert scheme.len != 0, "URI must start with a scheme"
  openDefault uri, scheme

const BrowserScheme = "https"
proc openDefaultBrowser*(url: string) = openDefault prepare url,BrowserScheme
proc openDefaultBrowser* = openDefault "about:blank", BrowserScheme

when isMainModule:
  when defined(js) and not defined(nodejs):
    openDefaultBrowser("https://nim-lang.org")
  else:
    if paramCount()>0:
      openDefaultBrowser paramStr 1
    else:
      openDefaultBrowser()
