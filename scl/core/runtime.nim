import tables

import objects

type
  LispEnvironment* = ref object of RootObj
    parentEnv*: LispEnvironment
    binding*: TableRef[string, LispT]

  LispRuntime* = object of RootObj
    readtable*: LispReadtable
    packageTable* : TableRef[string, LispPackage]
    currentPackage*: LispPackage


proc initEnvironment*(): LispEnvironment =
  var env = LispEnvironment()
  env.binding = newTable[string, LispT]()
  return env

proc addBinding*(env: LispEnvironment,
                 sym: LispSymbol,
                 val: LispT): LispEnvironment =
  env.binding[sym.name] = val
  return env

proc initRuntime*(): LispRuntime =
  var rt = LispRuntime()
  rt.packageTable = tables.newTable[string, LispPackage]()
  rt.toplevelEnv = initEnvironment()
  return rt
