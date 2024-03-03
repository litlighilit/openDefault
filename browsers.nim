
import std/strutils
import std/os


proc prepare(s: string): string =
  if s.contains("://"):
    result = s
  else:
    result = "file://" & absolutePath(s)

proc openDefaultBrowserRaw(url: string)

when defined(js):
  proc openDefaultBrowserRaw(url: string) =
    when defined(nodejs):
      const args = "{app:{name: m.apps.browser}}"
      {.emit: ["import(\"open\").then((m)=>m.default(", url.cstring,
        ",", args, "));" ].}
    else:
      {.emit: ["window.location.assign(", url.cstring, ");"].}
else:
  when defined(windows):
    import std/winlean
  else:
    import std/osproc


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
    when not defined(macosx):
      const
        DesktopAppDirs = [
          "~/.local/share/applications",
          "/usr/share/applications"
        ]
        DesktopLaunchers = [
          "gio launch $# $#",
          "gtk-launch $# $#"
        ]
      proc searchDesktopFile(fn: string): string =
        for dir in DesktopAppDirs:
          let pth = dir.expandTilde / fn
          if fileExists pth: return pth
      
    var browser{.threadvar.}: string ## 
    ## Under Linux, the full path of default browser;
    ## Under Mac OS X, the application identifier of default browser
    ##  (has been quoted via `quoteShell`)
    
  proc openDefaultBrowserRaw(url: string) =
    ## passing `url` to the browser "AS IS", will never add `file://` prefix
    when defined(windows):
      if browser == default typeof browser: browser = getDefaultBrowser()
      let arg = newWideCString(url)
      discard shellExecuteW(0'i32, nil, browser, arg, nil, SW_SHOWNORMAL)
    elif defined(macosx):
      if url == "about:blank":
        ## use `open -a <app> about:blank` command
        if browser == default typeof browser:
          browser = execProcess(
            "perl -MMac::InternetConfig" &
              """ -le 'print +(GetICHelper "http")[1]')" """,
              env = %{"VERSIONER_PERL_PREFER_32_BIT":"1"})
          browser = quoteShell(browser)
        discard execShellCmd("open -a " & browser & " about:blank")
      else:
        discard execShellCmd("open " & quoteShell(url))
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
      var desktopFn = execProcess("xdg-mime query default x-scheme-handler/http")
      if desktopFn.len != 0 and desktopFn[^1] == '\n': desktopFn.setLen desktopFn.len-1
      let pth = searchDesktopFile desktopFn
      if pth != "":
        let
          aPth = quoteShell pth
          aUrl = quoteShell url
        for laun in DesktopLaunchers:
          try:
            discard startProcess(laun % [aPth, aUrl],
              options={poUsePath, poEvalCommand})
            return
          except OSError: discard
      for b in getEnv("BROWSER").split(PathSep):
        test(b)


proc openDefaultBrowser*(url: string) =
  doAssert url.len > 0, "URL must not be empty string"
  openDefaultBrowserRaw prepare url

proc openDefaultBrowser* = openDefaultBrowserRaw "about:blank"

when isMainModule:
  when defined(js) and not defined(nodejs):
    openDefaultBrowser("https://nim-lang.org")
  else:
    if paramCount()>0:
      openDefaultBrowser paramStr 1
    else:
      openDefaultBrowser()
