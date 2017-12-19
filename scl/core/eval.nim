import eq
import objects
import print

proc eval(obj: LispT): LispT =
  if (obj of LispCharacter or
      obj of LispNumber or
      obj of LispNull or
      obj of LispArray or
      obj of LispVector or
      obj of LispString):
    return obj

  if obj of LispSymbol:
    var s = LispSymbol(obj)
    return s.value

  if obj of LispList:
    var
      c = LispList(obj)
      fn = LispSymbol(c.car)
      args = LispList(c.cdr)
    if eq(fn, LispSymbol(name: "quote")) of LispT:
      return c
    if eq(fn, LispSymbol(name: "function")) of LispT:
      return fn.function
    else:
      return fn

  else:
    echo "[otherwise!!]"
    return obj

import print

when isMainModule:
  var o = eval(
    LispList(car: LispSymbol(name: "hogte"),
             cdr: LispList (car: LispSymbol(name: "HOGE"),
                            cdr: LispList(car: LispNull(),
                                          cdr: LispNull()))))

  echo write(o)
