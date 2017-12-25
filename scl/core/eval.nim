import tables

import objects
import runtime
import print
import data_flow


proc eval(rt: LispRuntime,
          env: LispEnvironment,
          obj: LispT): LispT

proc evalSetq(env: LispEnvironment,
              pairs: LispList): LispT =
  if pairs.cdr of LispNull:
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

proc parseLambdaList(rt: LispRuntime,
                     env: LispEnvironment,
                     args: LispList): LispList =
  if args.cdr of LispNull:
    return LispList(car: eval(rt, env, args.car),
                    cdr: makeLispObject[LispNull]())
  else:
    var cdr = LispList(args.cdr)
    return LispList(car: eval(rt, env, args.car),
                    cdr: parseLambdaList(rt, env, cdr))

proc eval(rt: LispRuntime,
          env: LispEnvironment,
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
      var
        pred = eval(rt, env, args.car)
        rest = LispList(args.cdr)
        trueClause = rest.car
        falseCons = rest.cdr

      if pred of LispNull:
        if falseCons of LispNull:
          return makeLispObject[LispNull]()
        else:
          return eval(rt, env, LispList(falseCons).car)
      else:
        return eval(rt, env, trueClause)

    else:
      var lambdaList = parseLambdaList(rt, env, args)
      return lambdaList

  else:
    return obj

import print

when isMainModule:
  discard
