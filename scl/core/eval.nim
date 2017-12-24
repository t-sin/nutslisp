import tables

import objects
import print
import pure


proc eval(env: LispEnvironment,
          obj: LispT): LispT

proc evalSetq(env: LispEnvironment,
              pairs: LispList): LispT =
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
      return evalSetq(env, LispList(rest.cdr))

proc parseLambdaList(env: LispEnvironment,
                     args: LispList): LispList =
  if args.cdr of LispNull:
    return LispList(car: eval(env, args.car),
                    cdr: makeLispObject[LispNull]())
  else:
    var cdr = LispList(args.cdr)
    return LispList(car: eval(env, args.car),
                    cdr: parseLambdaList(env, cdr))

proc eval(env: LispEnvironment,
          obj: LispT): LispT =
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

    if isNil(env):
      if isNil(s.value):
        raise newException(Exception, "unbound-variable")
      else:
        return s.value
    elif tables.hasKey(env.binding, s.id):
      return env.binding[s.id]
    else:
      raise newException(Exception, "unbound-variable")

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
      return evalSetq(env, args)

    if op.name == "if":
      return nil

    else:
      var lambdaList = parseLambdaList(env, args)
      return lambdaList

  else:
    echo "t"
    return obj

import print

when isMainModule:
  # var o = eval(
  #   nil,
  #   LispList(car: LispSymbol(name: "setq"),
  #            cdr: LispList (car: LispSymbol(name: "HOGE", value: LispT()),
  #                           cdr: LispList(car: LispT(),
  #                                         cdr: LispNull()))))
  var
    s = makeLispObject[LispSymbol]()
    env = makeLispObject[LispEnvironment]()
  s.name = "symbol-name"
  s.value = makeLispObject[LispNull]()
  env.binding = tables.newTable[LispObjectId, LispT]()
  env.binding[s.id] = makeLispObject[LispT]()
  var o = eval(env, s)

  echo write(o)
