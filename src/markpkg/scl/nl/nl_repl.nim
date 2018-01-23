import sequtils
import tables

import objects
import nl_eval
import nl_print
import nl_read
import nl_runtime
import nl_streams
import utf8


proc readFrom(f: File,
              s: LispStream) =
  for cp in decodeBytes(f.readLine()):
    discard nl_writeElem(s, cp)

proc nl_repl() =
  let
    s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 256)
    rt = initRuntime()
    corePkg = initNlCorePackage(rt)

  rt.currentPackage = corePkg
  discard initKeywordPackage(rt)

  while true:
    write(stdout, rt.currentPackage.name & "> ")
    readFrom(stdin, s)
    stdout.writeLine(write(nl_eval(
      rt.currentPackage.environment, nl_read(rt, s))))

when isMainModule:
  nl_repl()
