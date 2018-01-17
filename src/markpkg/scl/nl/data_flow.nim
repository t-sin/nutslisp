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

proc lisp_eq*(obj1: LispT, obj2: LispT): LispT =
  var b = eq(obj1, obj2)
  if b:
    return makeLispObject[LispT]()
  else:
    return makeLispObject[LispNull]()

