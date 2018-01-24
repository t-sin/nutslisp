import tables

import objects
import nl_runtime
import nl_pure


proc eval*(rt: LispRuntime,
           env: LispEnvironment,
           obj: LispT): LispT

proc evalIf(rt: LispRuntime,
            env: LispEnvironment,
            args: LispList): LispT =
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

proc evalSetq(rt: LispRuntime,
              env: LispEnvironment,
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
      return evalSetq(rt, env, LispList(rest.cdr))

proc evalLambdaExp(rt: LispRuntime,
                   env: LispEnvironment,
                   args: LispList): LispFunction =
  var
    fn = makeLispObject[LispFunction]()
  if args.car of LispNull:
    fn.lambdaList = nil
  else:
    fn.lambdaList = LispList(args.car)
  fn.body = args.cdr
  return fn

proc bindLambdaList(rt: LispRuntime,
                    env: LispEnvironment,
                    lambdaList: LispList,
                    args: LispList,
                    newEnv: LispEnvironment = nil): LispEnvironment =
  var new_env: LispEnvironment

  # TODO: checks length of both lambdaList and args
  if isNil(newEnv):
    new_env = initEnvironment()
    new_env.parent = env
  else:
    new_env = newEnv

  if lambdaList of LispNull:
    return new_env
  elif lambdaList.cdr of LispNull:
    return new_env
  else:
    var
      lambda_cdr = LispList(lambdaList.cdr)
      args_cdr = LispList(args.cdr)

    if not (lambda_cdr.car of LispSymbol):
      raise newException(Exception, "invalid lambda list")
    else:
      newEnv.binding[lambda_cdr.car.id].value = args_cdr.car
      return bindLambdaList(rt, env, LispList(lambda_cdr.cdr), LispList(args_cdr.cdr), new_env)

proc list2seq(list: LispList): seq[LispT] =
  if list of LispNull:
    return @[]

  elif list.cdr of LispNull:
    return @[list.car]

  else:
    var rest = list2seq(LispList(list.cdr))
    rest.add(list.car)
    return rest

proc funcall(rt: LispRuntime,
             env: LispEnvironment,
             fn: LispFunction,
             args: LispList): LispT =
  if fn.nativeP:
    return fn.nativeBody(rt, list2seq(args))

  else:
    var newEnv = bindLambdaList(rt, env, fn.lambdaList, args)
    echo repr(newEnv)
    return eval(rt, newEnv, fn.body)

proc eval*(rt: LispRuntime,
           env: LispEnvironment,
           obj: LispT): LispT =
  if isNil(obj):
    raise newException(Exception, "nil!!")

  elif (obj of LispCharacter or
        obj of LispNumber or
        obj of LispNull or
#        obj of LispArray or
        obj of LispVector[LispT] or
        obj of LispString):
    return obj

  elif obj of LispSymbol:
    var s = LispSymbol(obj)

    if isNil(env):
      if isNil(s.value):
        raise newException(Exception, "unbound-variable")
      else:
        return s.value
    elif tables.hasKey(env.binding, s.id):
      return env.binding[s.id].value
    else:
      raise newException(Exception, "unbound-variable")

  elif obj of LispList:
    var
      c = LispList(obj)
      op = LispSymbol(c.car)
      args = LispList(c.cdr)

    if op.name == "quote":
      return args.car

    if op.name == "function":
      return op.function

    if op.name == "setq":
      return evalSetq(rt, env, args)

    if op.name == "if":
      return evalIf(rt, env, args)

    if op.name == "lambda":
      return evalLambdaExp(rt, env, args)

    else:
      let fn = op.function
      return funcall(rt, env, fn, args)

  else:
    return obj
