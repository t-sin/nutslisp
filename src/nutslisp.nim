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

    --- He doesn't bury nuts he hasn't picked up.
"""


when not defined(javascript):
  proc readFromStdin(s: LispStream, prompt: string): bool =
    let line = readLine(prompt)
    if isNil(line):
      return false

    discard historyAdd(line)
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
        echo "quit by user."
        quit(0)

      try:
        stdout.writeLine(print(eval(
          rt, rt.currentPackage.environment, nl_read(rt, s))))
      except Exception:
        let msg = getCurrentExceptionMsg()
        echo "Got exception with message '$msg'".format(["msg", msg])

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
      result = print(eval(
        rt, rt.currentPackage.environment, nl_read(rt, stream)))

    except Exception:
      let msg = getCurrentExceptionMsg()
      result = "\nGot exception with message '$msg'".format(["msg", msg])
