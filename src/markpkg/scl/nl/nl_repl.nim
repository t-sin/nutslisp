import sequtils

import nl_read
import nl_streams
import nl_print
import utf8


proc readFrom(f: File,
              s: LispCharacterInputStream) =
  for cp in decodeBytes(f.readLine()):
    discard nl_writeElem(s, cp)

proc nl_repl() =
  let s = makeLispCharacterInputStream(256)

  while true:
    write(stdout, "nl> ")
    readFrom(stdin, s)
    stdout.writeLine(write(nl_read(s)))

when isMainModule:
  nl_repl()
