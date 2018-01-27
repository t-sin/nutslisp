import macros
import sequtils
import strutils
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
  s.function = fn

  s = intern("atom", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_atom
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


proc readFromStdin(s: LispStream) =
  for cp in decodeBytes(stdin.readLine()):
    discard nl_writeElem(s, cp)

proc nl_repl*() =
  let
    s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 256)
    rt = initNlRuntime()

  while true:
    write(stdout, rt.currentPackage.name & "> ")
    readFromStdin(s)
    stdout.writeLine(write(eval(
      rt, rt.currentPackage.environment, nl_read(rt, s))))

when isMainModule:
  nl_repl()
