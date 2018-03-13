import tables

import nl_objects


proc makePackage*(name: string,
                  nicknames: seq[string],
                  uses: seq[string]): LispPackage =
  result = makeLispObject[LispPackage]()
  result.name = name
  result.nicknames = nicknames
  result.nicknames = uses
  result.symbols = newTable[string, LispSymbol]()

proc intern*(name: string,
             package: LispPackage): (LispSymbol, string) =
  for n in package.symbols.keys:
    if n == name:
      let s = package.symbols[n]

      if isNil(s.package):
        raise newException(Exception, "invalid symbol in package: " & s.package.name & ":" & s.name)

      if s.package == package:
        if s.exported:
          return (s, "external")
        else:
          return (s, "internal")

      else:
        return (s, "inherited")

  let s = makeLispObject[LispSymbol]()
  s.name = name
  s.package = package
  let IS = LispInternalSymbol(stype: lstInternal, symbol: s)
  package.symbols[s.name] = IS
  return (s, nil)
