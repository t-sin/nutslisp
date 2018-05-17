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
  if tables.hasKey(package.symbols, name):
    let s = package.symbols[name]

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
  package.symbols[name] = s
  return (s, nil)
