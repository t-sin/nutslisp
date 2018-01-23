import sequtils
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
    pkgName = "nl"
    pkg = initPackage(pkgName, @[])

  var
    s: LispSymbol
    fn: LispFunction

  s = intern("eq", pkg)[0]
  fn = makeLispObject[LispFunction]()
  fn.nativeP = true
  fn.nativeBody = nl_eq
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


proc readFrom(f: File,
              s: LispStream) =
  for cp in decodeBytes(f.readLine()):
    discard nl_writeElem(s, cp)

proc nl_repl() =
  let
    s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 256)
    rt = initNlRuntime()

  while true:
    write(stdout, rt.currentPackage.name & "> ")
    readFrom(stdin, s)
    stdout.writeLine(write(eval(
      rt, rt.currentPackage.environment, nl_read(rt, s))))

when isMainModule:
  nl_repl()
