import tables

import core.objects
import core.runtime
import core.pure

proc initCorePackage*(rt: LispRuntime): LispRuntime =
  var
    pkgName = "scl.core"
    pkg = initPackage(pkgName, @[])

  # variable
  discard lisp_intern(rt, "hoge", pkg)
  # functions

  rt.packageTable[pkgName] = pkg
  return rt

proc makeSclRuntime*(): LispRuntime =
  var
    rt = initRuntime()

  discard initCorePackage(rt)

  return rt


when isMainModule:
  var
    rt = makeSclRuntime()

  echo repr(rt.packageTable["scl.core"])
