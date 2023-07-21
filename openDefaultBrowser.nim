
import std/osproc
proc openDefaultBrowser*() =
  include ./lib4 # or 2. But lib_importcpp is too big (c++ backend)

when isMainModule:
  openDefaultBrowser()