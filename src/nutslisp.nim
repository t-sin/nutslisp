import sequtils
import strutils

import linenoise

import nutslisppkg.utf8
import nutslisppkg.objects
import nutslisppkg.nl_streams
import nutslisppkg.nl_print
import nutslisppkg.nl_read
import nutslisppkg.nl_eval
import nutslisppkg.bootstrap


let nutslisp_logo* = """
 ⣀⡀ ⡀⢀ ⣰⡀ ⢀⣀   ⡇ ⠄ ⢀⣀ ⣀⡀
 ⠇⠸ ⠣⠼ ⠘⠤ ⠭⠕   ⠣ ⠇ ⠭⠕ ⡧⠜
"""


when not defined(javascript):
  proc readFromStdin(s: LispStream, prompt: string): bool =
    let line = readLine(prompt)
    if isNil(line):
      return false

    for cp in decodeBytes($(line)):
      discard nl_writeElem(s, cp)
    return true

  proc nl_repl*() =
    let
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 256)
      rt = initNlRuntime()

    while true:
      let readP = readFromStdin(s, rt.currentPackage.name & "> ")
      if not readP:
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
  var rt = initNlRuntime()

  proc getCurrentPackageName(): cstring {.exportc.} =
    return rt.currentPackage.name

  proc readFromString*(str: cstring): cstring {.exportc.} =
    let stream = makeLispStream[LispCodepoint](
      setCharacter, sdtInput,
      256, toSeq(decodeBytes($(str))))

    try:
      result = write(eval(
        rt, rt.currentPackage.environment, nl_read(rt, stream)))

    except Exception:
      let msg = getCurrentExceptionMsg()
      result = "\nGot exception with message '$msg'".format(["msg", msg])
