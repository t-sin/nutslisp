import macros
import strutils

import objects
import runtime

proc lisp_atom*(rt, LispRuntime, obj: LispT): bool =
  if obj of LispCons:
    return false
  else:
    return true

template objAreTyped(t: untyped): untyped =
  obj1 of t and obj2 of t

macro eqReturn(t: untyped, eqexp: untyped): typed =
  result = newNimNode(nnkStmtList)
  for n in 1..2:
    var
      varDef = newNimNode(nnkVarSection)
      identDef = newNimNode(nnkIdentDefs)
      callExp = newNimNode(nnkCall)

    callExp.add(t)
    callExp.add(newIdentNode("obj" & $(n)))
    identDef.add(newIdentNode("o" & $(n)))
    identDef.add(newEmptyNode())
    identDef.add(callExp)
    varDef.add(identDef)
    result.add(varDef)

  var
    returnStmt = newNimNode(nnkReturnStmt)
  returnStmt.add(eqexp)
  result.add(returnStmt)

proc eq*(obj1: LispT, obj2: LispT): bool =
  if objAreTyped(LispNull):
    eqReturn(LispNull, true)

  else:
    return obj1.id == obj2.id

proc lisp_eq*(obj1: LispT, obj2: LispT): LispT =
  var b = eq(obj1, obj2)
  if b:
    return makeLispObject[LispT]()
  else:
    return makeLispObject[LispNull]()

proc lisp_car*(rt: LispRuntime, c: LispCons): LispT =
  return c.car

proc lisp_cdr*(rt: LispRuntime, c: LispCons): LispT =
  return c.cdr

proc lisp_cons*(rt: LispRuntime, obj1: LispT, obj2: LispT): LispT =
  return LispCons(car: obj1, cdr: obj2)
