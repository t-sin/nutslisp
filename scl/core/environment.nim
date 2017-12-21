import tables

import objects


type
  LispRuntime* = ref object of RootObj
    readtable*: LispReadtable
    packageTable* : TableRef[string, LispPackage]
    currentPackage*: LispPackage


proc initPackage*(name: string,
                  nicknames: seq[string]): LispPackage =
  var pkg = LispPackage()
  pkg.name = name
  pkg.nicknames = nicknames
  pkg.symbolTable = tables.newTable[string, LispSymbol]()
  return pkg

proc initEnvironment*(): LispEnvironment =
  var env = LispEnvironment()
  env.binding = newTable[string, LispT]()
  return env

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

proc intern(name: string,
            package: LispPackage): (LispSymbol, string) =
  if tables.hasKey(package.symbolTable, name):
    return (package.symbolTable[name], "existed")  # internal or external
  else:
    var s = LispSymbol(name: name)
    package.symbolTable[name] = s
    return (s, "created")

proc lisp_intern*(rt: LispRuntime,
                 name: string,
                 package: LispT): LispSymbol =
  var pkg = getPackage(rt, package)
  if isNil(pkg):
    return intern(name, rt.currentPackage)[0]
  else:
    return intern(name, pkg)[0]

proc resolveOnRuntime(s: LispSymbol,
                      rt: LispRuntime): (bool, LispT) =
  if tables.hasKey(rt.currentPackage.symbolTable, s.name):
    return (true, rt.currentPackage.symbolTable[s.name])
  else:
    return (false, nil)

proc resolveName*(s: LispSymbol,
                  rt: LispRuntime,
                  env: LispEnvironment): (bool, LispT) =
  if env == nil:
    return resolveOnRuntime(s, rt)
  elif tables.hasKey(env.binding, s.name):
    return (true, env.binding[s.name])
  else:
    return resolveName(s, rt, env.parent)


proc bindValue*(rt: LispRuntime,
                s: LispSymbol,
                val: LispT): LispEnvironment =

  return nil

proc unbindValue() =
  discard
