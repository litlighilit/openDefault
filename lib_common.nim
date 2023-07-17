# to be included in `lib*.nim

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

discard execShellCmd(cmd)
