import macros
import tables

import objects
import nl_eval
import nl_print
import nl_pure
import nl_read
import nl_runtime
import nl_streams
import utf8


proc initKeywordPackage*(rt: LispRuntime): LispPackage =
  var
    pkgName = "keyword"
    pkg = initPackage(pkgName, @[])

  rt.packageTable[pkgName] = pkg
  return pkg

proc initNlCorePackage*(rt: LispRuntime): LispPackage =
  var
    pkgName = "nuts-lisp"
    pkg = initPackage(pkgName, @[])

  rt.currentPackage = pkg

  var
    s: LispSymbol
    fn: LispFunction

  s = intern("eq", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_eq
  s.package = rt.currentPackage
  s.function = fn

  s = intern("atom", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_atom
  s.package = rt.currentPackage
  s.function = fn

  s = intern("car", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_car
  s.package = rt.currentPackage
  s.function = fn

  s = intern("cdr", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_cdr
  s.package = rt.currentPackage
  s.function = fn

  s = intern("cons", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_cons
  s.package = rt.currentPackage
  s.function = fn

  rt.packageTable[pkgName] = pkg

  return pkg

proc initNlRuntime*(): LispRuntime =
  let
    rt = initRuntime()
    corePkg = initNlCorePackage(rt)

  rt.currentPackage = corePkg
  discard initKeywordPackage(rt)

  return rt
