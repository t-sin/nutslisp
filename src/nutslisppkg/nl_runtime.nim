import tables

import nl_objects


proc makePackage1*(name: string,
                   nicknames: seq[string],
                   uses: seq[string]): LispPackage =
  result = makeLispObject[LispPackage]()
  result.name = name
  result.nicknames = nicknames
  result.nicknames = uses
  result.symbols = newTable[string, LispSymbol]()
