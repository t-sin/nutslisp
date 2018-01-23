from os import commandLineParams

from markpkg.scl.nl.nutslisp import nl_repl

proc usage(): void =
  echo """
mark - little squirrel program

usage: mark STR
"""

when isMainModule:
  var
    args: seq[string] = commandLineParams()

  # if len(args) < 1:
  #   usage()
  #   quit(0)

  nl_repl()
