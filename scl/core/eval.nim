import tables

import objects
import runtime
import print
import data_flow


proc eval(env: LispEnvironment,
          obj: LispT): LispT

proc evalIf(env: LispEnvironment,
            args: LispList): LispT =
  var
    pred = eval(env, args.car)
    rest = LispList(args.cdr)
    trueClause = rest.car
    falseCons = rest.cdr

  if pred of LispNull:
    if falseCons of LispNull:
      return makeLispObject[LispNull]()
    else:
      return eval(env, LispList(falseCons).car)
  else:
    return eval(env, trueClause)

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

proc evalLambdaExp(env: LispEnvironment,
                   args: LispList): LispFunction =
  var
    fn = makeLispObject[LispFunction]()
  if args.car of LispNull:
    fn.lambdaList = nil
  else:
    fn.lambdaList = LispList(args.car)
  fn.body = nil
  return fn

proc bindLambdaList(env: LispEnvironment,
                    lambdaList: LispList,
                    args: LispList,
                    newEnv: LispEnvironment = nil): LispEnvironment =
  # this should return an (lexical) environment
  var new_env: LispEnvironment

  if isNil(newEnv):
    new_env = initEnvironment()
    new_env.parent = env
  else:
    new_env = newEnv

  if lambdaList.cdr of LispNull:
    return new_env
  else:
    var
      lambda_cdr = LispList(lambdaList.cdr)
      args_cdr = LispList(args.cdr)

    if not (lambda_cdr.car of LispSymbol):
      raise newException(Exception, "invalid lambda list")
    else:
      newEnv.binding[lambda_cdr.car.id] = args_cdr.car
      return bindLambdaList(env, LispList(lambda_cdr.cdr), LispList(args_cdr.cdr), new_env)

proc funcall(env: LispEnvironment,
             fn: LispFunction,
             args: varargs[LispT]): LispT =
  var
    arglist: LispList = nil
    cons: LispList = nil

  for a in args:
    if not isNil(arglist):
      cons = argList
    arglist = makeLispObject[LispList]()
    cons.cdr = arglist
    arglist.car = a

  return eval(bindLambdaList(env, fn.lambdaList, arglist), fn.body)

proc hello_fn(args: varargs[LispT]): LispT =
  echo "first your function!!"
  return makeLispObject[LispNull]()

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
      return evalIf(env, args)

    if op.name == "lambda":
      return evalLambdaExp(env, args)

    else:
      # var
      #   newEnv = bindLambdaList(env, args)
      var fn = makeLispObject[LispFunction]()
      fn.lambdaList = makeLispObject[LispNull]()
      fn.body = LispList(car: LispSymbol(name: "quote"),
                         cdr: LispList(car: LispNull(), cdr: LispNull()))
      return funcall(env, fn, [])

  else:
    return obj

import print

when isMainModule:
  var result = eval(initEnvironment(),
                    LispList(car: LispSymbol(name: "hoge"),
                             cdr: LispNull()))
