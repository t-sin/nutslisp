import tables

import nl_objects


proc initEnvironment*(): LispEnvironment =
  var env = makeLispObject[LispEnvironment]()
  env.binding = newTable[LispObjectId, LispSymbol]()
  return env

proc initPackage*(name: string,
                  nicknames: seq[string]): LispPackage =
  var pkg = LispPackage()
  pkg.name = name
  pkg.nicknames = nicknames
  pkg.environment = initEnvironment()
  return pkg

proc initRuntime*(): LispRuntime =
  var rt = LispRuntime()
  rt.packageTable = tables.newTable[string, LispPackage]()
  return rt

proc getPackage(rt: LispRuntime,
                pkgDesignator: LispT): LispPackage =
  if pkgDesignator of LispPackage:
    return LispPackage(pkgDesignator)
  elif pkgDesignator of LispSymbol:
    var s = LispSymbol(pkgDesignator)
    return rt.packageTable[s.name]
  else:
    return nil

proc intern*(name: string,
             package: LispPackage): (LispSymbol, string) =
  for v in package.environment.binding.values:
    if v.name == name:
      return (v, "existed")

  let s = makeLispObject[LispSymbol]()
  s.name = name
  s.package = package
  package.environment.binding[s.id] = s
  return (s, "created")

proc lisp_intern*(rt: LispRuntime,
                  name: string,
                  package: LispT): LispSymbol =
  var pkg = getPackage(rt, package)
  if isNil(pkg):
    return intern(name, rt.currentPackage)[0]
  else:
    return intern(name, pkg)[0]
