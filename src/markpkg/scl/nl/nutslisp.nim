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

macro defNativeFun(name: untyped): untyped =
  var source = ""
  source.add("s = intern(\"$name\", pkg)[0]\n".format("name", name))
  source.add("fn = makeLispObject[LispFunction]()\n")
  source.add("fn.nativeP = true\n")
  source.add("fn.nativeBody = nl_$name\n".format("name", name.strVal))
  source.add("s.function = fn\n")
  return parseStmt(source)

proc initNlCorePackage*(rt: LispRuntime): LispPackage =
  var
    pkgName = "nl"
    pkg = initPackage(pkgName, @[])

  var
    s: LispSymbol
    fn: LispFunction

  defNativeFun("eq")

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