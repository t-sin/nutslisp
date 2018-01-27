import macros

import objects
import nl_runtime


template objAreTyped(t: untyped): untyped =
  obj1 of t and obj2 of t

macro eqReturn(t: untyped, eqexp: untyped): typed =
  result = newNimNode(nnkStmtList)
  for n in 1..2:
    var
      varDef = newNimNode(nnkVarSection)
      identDef = newNimNode(nnkIdentDefs)
      callExp = newNimNode(nnkCall)

    result.add(macros.parseStmt("{.push hint[XDeclaredButNotUsed]: off.}"))
    callExp.add(t)
    callExp.add(newIdentNode("obj" & $(n)))
    identDef.add(newIdentNode("o" & $(n)))
    identDef.add(newEmptyNode())
    identDef.add(callExp)
    varDef.add(identDef)
    result.add(varDef)
    result.add(macros.parseStmt("{.pop.}"))

  var
    returnStmt = newNimNode(nnkReturnStmt)
  returnStmt.add(eqexp)
  result.add(returnStmt)

proc eq*(obj1: LispT, obj2: LispT): bool =
  if objAreTyped(LispNull):
    eqReturn(LispNull, true)

  else:
    return obj1.id == obj2.id

proc nl_eq*(rt: LispRuntime,
            args: LispList): LispT =
  let
    a = args.car
    b = LispList(args.cdr).car

  if eq(a, b):
    return makeLispObject[LispT]()
  else:
    return makeLispObject[LispNull]()

proc atom*(obj: LispT): bool =
  if obj of LispCons:
    return false
  elif obj of LispNull:
    return false
  else:
    return true

proc nl_atom*(rt: LispRuntime, args: LispList): LispT =
  let a = args.car

  if atom(a):
    return makeLispObject[LispT]()
  else:
    return makeLispObject[LispNull]()

proc nl_car*(rt: LispRuntime, c: LispCons): LispT =
  return c.car

proc nl_cdr*(rt: LispRuntime, c: LispCons): LispT =
  return c.cdr

proc nl_cons*(rt: LispRuntime, obj1: LispT, obj2: LispT): LispT =
  return LispCons(car: obj1, cdr: obj2)
