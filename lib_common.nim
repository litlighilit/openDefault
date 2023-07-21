# to be included in `lib*.nim
const lib_ed = declared(osproc)
when not lib_ed: import std/osproc

proc getDefaultBrowser: string =
  var buf: cstring
  discard getDefaultBrowser(buf)
  result = $buf
  dealloc buf

const Q = '"'
let qpath = Q & getDefaultBrowser() & Q

const url{.strdefine.} = "about:blank"
const arg = ' ' & url

let cmd = qpath & arg


try:
  # use `startProcess` to avoid blocking
  discard startProcess(cmd, options={poEvalCommand})
except OSError:
  discard
