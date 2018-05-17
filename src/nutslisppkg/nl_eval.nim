import strutils
import tables

import nl_objects
import nl_bootstrap
import nl_pure


proc eval*(rt: LispRuntime,
           env: LispLexicalEnvironment,
           obj: LispT): LispT

proc evalIf(rt: LispRuntime,
            env: LispLexicalEnvironment,
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
              env: LispLexicalEnvironment,
              pairs: LispList): LispT =
  if pairs.cdr of LispNull:
    raise newException(Exception, "invalid setq")
  else:
    var
      rest = LispList(pairs.cdr)
      sym = LispSymbol(pairs.car)
      val = eval(rt, env, rest.car)

    sym.value = val
    if rest.cdr of LispNull:
      return val
    else:
      return evalSetq(rt, env, LispList(rest.cdr))

proc parseArg(args: LispList,
              lambdaList: LispLambdaList): LispLambdaList =

  proc exists(ordinal: seq[LArg], s: LispSymbol): bool =
    for i in 0..<ordinal.len:
      if ordinal[i].name.id == s.id:
        return true
    return false

  let
    arg = LispSymbol(args.car)
    rest = LispList(args.cdr)

  if exists(lambdaList.ordinal, arg):
    raise newException(Exception, "bad lambda list: '" & $(arg.name) & "' is already apeared")
  else:
    let a = makeLispObject[LArg]()
    a.name = arg
    lambdaList.ordinal.add(a)

  if rest of LispNull:
    return lambdaList
  else:
    return parseArg(rest, lambdaList)

proc parseArgs(args: LispList): LispLambdaList =
  let lambdaList = makeLispObject[LispLambdaList]()
  lambdaList.ordinal = newSeq[LArg]()
  # lambdaList.optional = newTable[LispObjectId, LArg]()
  # lambdaList.keyword = newTable[LispObjectId, LArg]()

  return parseArg(args, lambdaList)

proc evalLambdaExp(rt: LispRuntime,
                   env: LispLexicalEnvironment,
                   args: LispList): LispFunction =
  var
    fn = makeLispObject[LispFunction]()
  if args.car of LispNull:
    fn.lambdaList = nil
  else:
    fn.lambdaList = parseArgs(LispList(args.car))
  fn.body = args.cdr
  return fn

proc evalProgn(rt: LispRuntime,
               env: LispLexicalEnvironment,
               body: LispList): LispT =
  var
    car = body.car
    cdr = body.cdr

  while true:
    if cdr of LispNull:
      return eval(rt, env, car)
    else:
      discard eval(rt, env, car)

    car = LispList(cdr).car
    cdr = LispList(cdr).cdr

proc evalArgs(rt: LispRuntime,
              env: LispLexicalEnvironment,
              args: LispList): LispList =
  let
    val = eval(rt, env, args.car)
    cdr = LispList(args.cdr)
    cons = makeLispObject[LispList]()

  cons.car = val
  if cdr of LispNull:
    cons.cdr = makeLispObject[LispNull]()
  else:
    cons.cdr = evalArgs(rt, env, cdr)

  return cons

proc bindArgs(rt: LispRuntime,
              env: LispLexicalEnvironment,
              lambdaList: LispLambdaList,
              args: LispList,
              index: int = 0): LispLexicalEnvironment =
  let
    newEnv = makeLispObject[LispLexicalEnvironment]()
    val = eval(rt, env, args.car)
    rest = LispList(args.cdr)
  newEnv.parent = env
  newEnv.variables = newTable[LispSymbolId, LispT]()

  if index >= lambdaList.ordinal.len:
    raise newException(Exception, "too many arguments")
  else:
    newEnv.variables[lambdaList.ordinal[index].id] = val # oops type mismatch

  return newEnv

proc funcall(rt: LispRuntime,
             env: LispLexicalEnvironment,
             fn: LispFunction,
             args: LispList): LispT =
  if isNil(fn):
    raise newException(Exception, "function is undefined")

  if fn.nativeP:
    return fn.nativeBody(rt, evalArgs(rt, env, args))

  else:
    var newEnv = bindArgs(rt, env, fn.lambdaList, args)
    return evalProgn(rt, newEnv, LispList(fn.body))

proc eval*(rt: LispRuntime,
           env: LispLexicalEnvironment,
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
    elif s.package == rt.keywordPkg:
      return s
    elif tables.hasKey(env.variables, s.id):
      return env.variables[s.id]
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
      return LispSymbol(args.car).function

    if op.name == "setq":
      return evalSetq(rt, env, args)

    if op.name == "if":
      return evalIf(rt, env, args)

    if op.name == "progn":
      return evalProgn(rt, env, args)

    if op.name == "lambda":
      return evalLambdaExp(rt, env, args)

    else:
      let fn = op.function
      return funcall(rt, env, fn, args)

  else:
    return obj
