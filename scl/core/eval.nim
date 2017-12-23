import objects
import print
import pure


proc eval(obj: LispT): LispT

proc evalSetq(pairs: LispList): LispT =
  if pairs.cdr of LispNil:
    raise newException(Exception, "invalid setq")
  else:
    var
      rest = LispList(pairs.cdr)
      sym = LispSymbol(pairs.car)
      val = rest.car

    sym.value = val
    if rest.cdr of LispNull:
      return val
    else:
      return evalSetq(LispList(rest.cdr))

proc parseLambdaList(args: LispList): LispList =
  if args.cdr of LispNull:
    return LispList(car: eval(args.car),
                    cdr: makeLispObject[LispNull]())
  else:
    var cdr = LispList(args.cdr)
    return LispList(car: eval(args.car),
                    cdr: parseLambdaList(cdr))

proc eval(obj: LispT): LispT =
  if isNil(obj):
    raise newException(Exception, "nil!!")

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
      op = LispSymbol(c.car)
      args = LispList(c.cdr)

    if op.name == "quote":
      return c

    if op.name == "function":
      return op.function

    if op.name == "setq":
      return evalSetq(args)

    if op.name == "cond":
      return nil

    else:
      var lambdaList = parseLambdaList(args)
      return lambdaList

  else:
    echo "t"
    return obj

import print

when isMainModule:
  var o = eval(
    LispList(car: LispSymbol(name: "setq"),
             cdr: LispList (car: LispSymbol(name: "HOGE", value: LispT()),
                            cdr: LispList(car: LispT(),
                                          cdr: LispNull()))))

  echo write(o)
