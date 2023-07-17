
import std/[dynlib, os] 

proc openDefaultBrowser*() =
  include ./lib

when isMainModule:
  openDefaultBrowser()