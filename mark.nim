from os import commandLineParams

proc usage(): void =
  echo """
mark - little squirrel program

usage: mark STR
"""

when isMainModule:
  var
    args: seq[string] = commandLineParams()

  if len(args) < 1:
    usage()
    quit(0)
