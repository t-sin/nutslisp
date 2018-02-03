import objects


proc fset*(s: LispSymbol,
          fn: LispFunction) =
  s.function = fn

proc nl_fset*(rt: LispRuntime,
             args: LispList): LispT =
  let
    s = LispSymbol(args.car)
    fn = LispFunction(LispList(args.cdr).car)

  fset(s, fn)
  return rt.symbolNil
