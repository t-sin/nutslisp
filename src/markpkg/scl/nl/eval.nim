import tables

import objects
import nl_runtime
import print
import data_flow


proc nl_eval*(env: LispEnvironment,
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
  fn.body = args.cdr
  return fn

proc bindLambdaList(env: LispEnvironment,
                    lambdaList: LispList,
                    args: LispList,
                    newEnv: LispEnvironment = nil): LispEnvironment =
  var new_env: LispEnvironment

  # TODO: checks length of both lambdaList and args
  if isNil(newEnv):
    new_env = initEnvironment()
    new_env.parent = env
    echo "lambdalist = " & write(lambdaList)
    echo "args = " & write(args)
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
      newEnv.binding[lambda_cdr.car.id] = args_cdr.car
      return bindLambdaList(env, LispList(lambda_cdr.cdr), LispList(args_cdr.cdr), new_env)

proc list2seq(list: LispList): seq[LispT] =
  if list of LispNull:
    return @[]

  elif list.cdr of LispNull:
    return @[list.car]

  else:
    var rest = list2seq(LispList(list.cdr))
    rest.add(list.car)
    return rest

proc funcall(env: LispEnvironment,
             fn: LispFunction,
             args: LispList): LispT =
  if fn.nativeP:
    return fn.nativeBody(list2seq(args))

  else:
    var newEnv = bindLambdaList(env, fn.lambdaList, args)
    echo repr(newEnv)
    return eval(newEnv, fn.body)

proc hello_fn(args: varargs[LispT]): LispT =
  echo "first your function!!"
  return makeLispObject[LispNull]()

proc nl_eval*(env: LispEnvironment,
              obj: LispT): LispT =
  if isNil(obj):
    raise newException(Exception, "nil!!")

  elif (obj of LispCharacter or
        obj of LispNumber or
        obj of LispNull or
        obj of LispArray[LispT] or
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
      return LispSymbol(env.binding[s.id]).value
    else:
      raise newException(Exception, "unbound-variable")

  elif obj of LispList:
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
      # var newEnv = bindLambdaList(env, args)
      var fn = op.function
      return funcall(env, fn, args)

  else:
    return obj

import print

when isMainModule:
  var
    env = initEnvironment()
    fn_name = makeLispObject[LispSymbol]()
    fn = makeLispObject[LispFunction]()

  fn.nativeP = true
  fn.nativeBody = hello_fn
  fn_name.name = "hoge"
  fn_name.function = fn
  env.binding[fn_name.id] = fn

  var result = eval(env,
                    LispList(car: fn_name, cdr: LispNull()))
