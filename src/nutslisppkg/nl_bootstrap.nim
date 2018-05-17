import macros
import tables

import nl_objects
import nl_dataflow
import nl_eval
import nl_print
import nl_pure
import nl_read
import nl_packages
import nl_streams
import utf8


proc initKeywordPackage*(rt: LispRuntime): LispPackage =
  var
    pkgName = "keyword"
    pkg = makePackage(pkgName, @[], @[])

  rt.packageTable[pkgName] = pkg
  return pkg

proc initNlCorePackage*(rt: LispRuntime): LispPackage =
  var
    pkgName = "nuts-lisp"
    pkg = makePackage(pkgName, @[], @[])

  rt.currentPackage = pkg

  var
    s: LispSymbol
    fn: LispFunction

  s = intern("t", rt.currentPackage)[0]
  s.package = rt.currentPackage
  rt.symbolT = makeLispObject[LispT]()
  s.value = rt.symbolT

  s = intern("nil", rt.currentPackage)[0]
  s.package = rt.currentPackage
  rt.symbolNil = makeLispObject[LispNull]()
  s.value = rt.symbolNil

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

  s = intern("fset", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_fset
  s.package = rt.currentPackage
  s.function = fn

  rt.packageTable[pkgName] = pkg

  return pkg

proc initNlRuntime*(): LispRuntime =
  let rt = LispRuntime()
  rt.packageTable = newTable[string, LispPackage]()

  let corePkg = initNlCorePackage(rt)
  rt.currentPackage = corePkg
  rt.keywordPkg = initKeywordPackage(rt)

  return rt
