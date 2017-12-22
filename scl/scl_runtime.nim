import tables

import core.objects
import core.runtime
import core.pure

proc initKeywordPackage(rt: LispRuntime): LispPackage =
  var
    pkgName = "keyword"
    pkg = initPackage(pkgName, @[])

  rt.packageTable[pkgName] = pkg
  return pkg

proc initCorePackage(rt: LispRuntime): LispPackage =
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

  discard initKeywordPackage(rt)
  discard initCorePackage(rt)

  return rt


when isMainModule:
  var
    rt = makeSclRuntime()

  echo repr(rt.packageTable["scl.core"])
