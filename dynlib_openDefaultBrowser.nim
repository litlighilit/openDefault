
import std/[dynlib, osproc] 

proc openDefaultBrowser*() =
  include ./lib

when isMainModule:
  openDefaultBrowser()