import tables

import objects


type
  LispRuntime* = ref object of RootObj
    readtable*: LispReadtable
    packageTable* : TableRef[string, LispPackage]
    currentPackage*: LispPackage


proc initEnvironment*(): LispEnvironment =
  var env = makeLispObject[LispEnvironment]()
  env.binding = newTable[LispObjectId, LispT]()
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

proc intern(name: LispSymbol,
            package: LispPackage): (LispSymbol, string) =
  if tables.hasKey(package.environment.binding, name.id):
    return (name, "existed")  # internal or external
  else:
    name.package = package
    package.environment.binding[name.id] = name
    return (name, "created")

proc lisp_intern*(rt: LispRuntime,
                  name: LispSymbol,
                  package: LispT): LispSymbol =
  var pkg = getPackage(rt, package)
  if isNil(pkg):
    return intern(name, rt.currentPackage)[0]
  else:
    return intern(name, pkg)[0]

proc bindValue*(rt: LispRuntime,
                s: LispSymbol,
                val: LispT): LispEnvironment =

  return nil

proc unbindValue() =
  discard
