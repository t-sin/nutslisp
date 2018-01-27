import macros
import sequtils
import strutils
import tables

import nutslisppkg.objects
import nutslisppkg.nl_eval
import nutslisppkg.nl_print
import nutslisppkg.nl_pure
import nutslisppkg.nl_read
import nutslisppkg.nl_runtime
import nutslisppkg.nl_streams
import nutslisppkg.utf8


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

  s = intern("car", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_car
  s.function = fn

  s = intern("cdr", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_cdr
  s.function = fn

  s = intern("cons", rt.currentPackage)[0]
  fn = makeLispObject[LispFunction]()
  fn.lambdaList = nil
  fn.nativeP = true
  fn.nativeBody = nl_cons
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


let nutslisp_logo* = """
 ⣀⡀ ⡀⢀ ⣰⡀ ⢀⣀   ⡇ ⠄ ⢀⣀ ⣀⡀
 ⠇⠸ ⠣⠼ ⠘⠤ ⠭⠕   ⠣ ⠇ ⠭⠕ ⡧⠜
"""

when not defined(javascript):
  proc readFromStdin(s: LispStream) =
    for cp in decodeBytes(stdin.readLine()):
      discard nl_writeElem(s, cp)

  proc nl_repl*() =
    let
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 256)
      rt = initNlRuntime()

    while true:
      write(stdout, rt.currentPackage.name & "> ")

      try:
        readFromStdin(s)
      except Exception:
        echo "\nquit by user."
        quit(0)

      try:
        stdout.writeLine(write(eval(
          rt, rt.currentPackage.environment, nl_read(rt, s))))
      except Exception:
        let
          msg = getCurrentExceptionMsg()

        echo "\nGot exception with message '$msg'".format(["msg", msg])

  when isMainModule:
    echo nutslisp_logo
    nl_repl()

when defined(javascript):
  proc readFromString*(str: string): string {.exportc.} =
    let stream = makeLispStream[LispCodepoint](
      setCharacter, sdtInput,
      256, toSeq(decodeBytes(str)))
    write(nl_read(initNlRuntime(), stream))
