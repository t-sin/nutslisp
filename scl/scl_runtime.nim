import tables

import core.objects
import core.runtime
import core.pure

proc initCorePackage*(rt: LispRuntime): LispRuntime =
  var
    pkgName = "scl.core"
    pkg = initPackage(pkgName, @[])
    s: LispSymbol

  # variable
  s = makeLispObject[LispSymbol]()
  s.name = "hoge"
  discard lisp_intern(rt, s, pkg)

  # functions

  rt.packageTable[pkgName] = pkg
  return pkg

proc makeSclRuntime*(): LispRuntime =
  var
    rt = initRuntime()

  discard initCorePackage(rt)

  return rt


when isMainModule:
  var
    rt = makeSclRuntime()

  echo repr(rt.packageTable["scl.core"])
