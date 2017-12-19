import objects
import print
import pure

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
    proc eval_args(args: LispList): LispList =
      if args.cdr of LispNull:
        return LispList(car: eval(args.car),
                        cdr: LispNull())
      else:
        var cdr = LispList(args.cdr)
        return LispList(car: eval(args.car),
                        cdr: eval_args(cdr))

    var
      c = LispList(obj)
      fn = LispSymbol(c.car)
      args = LispList(c.cdr)

    if fn.name == "quote":
      return c
    if fn.name == "function":
      return fn.function
    else:
      var evaledArgs = eval_args(args)
      return evaledArgs

  else:
    echo "[otherwise!!]"
    return obj

import print

when isMainModule:
  var o = eval(
    LispList(car: LispSymbol(name: "hogte"),
             cdr: LispList (car: LispSymbol(name: "HOGE", value: LispT()),
                            cdr: LispList(car: LispNull(),
                                          cdr: LispNull()))))

  echo write(o)
