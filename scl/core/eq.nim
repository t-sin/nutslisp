import macros
import strutils

import objects

proc b2lb(b: bool): LispT =
  if b:
    return LispT()
  else:
    return LispNull()

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
  if objAreTyped(LispCharacter):
    eqReturn(LispCharacter, o1.codepoint == o2.codepoint)

  elif objAreTyped(LispNull):
    eqReturn(LispNull, true)

  elif objAreTyped(LispSymbol):
    eqReturn(LispSymbol, o1.name == o2.name)

  else:
    return false
