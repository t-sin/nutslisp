import core.objects
import core.environment
import core.pure

proc initCorePackage*(rt: LispRuntime): LispRuntime =
  var
    pkgName = "scl.core"
    pkg = initPackage(pkgName, @[])

  # variable

  # functions

  return rt

proc makeSclRuntime*(): LispRuntime =
  var
    rt = initRuntime()

  discard initCorePackage(rt)

  return rt


when isMainModule:
  var
    rt = makeSclRuntime()
