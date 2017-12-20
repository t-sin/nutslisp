import tables

import objects

type
  LispEnvironment* = ref object of RootObj
    parent*: LispEnvironment
    binding*: TableRef[string, LispT]

  LispRuntime* = object of RootObj
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

