import macros
import strutils

import objects
import print

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
      castExp = newNimNode(nnkCast)

    castExp.add(t)
    castExp.add(newIdentNode("obj" & $(n)))
    identDef.add(newIdentNode("o" & $(n)))
    identDef.add(newEmptyNode())
    identDef.add(castExp)
    varDef.add(identDef)
    result.add(varDef)

  var
    returnStmt = newNimNode(nnkReturnStmt)
    callStmt = newNimNode(nnkCall)
  callStmt.add(newIdentNode("b2lb"))
  callStmt.add(eqexp)
  returnStmt.add(callStmt)
  result.add(returnStmt)


proc eq(obj1: LispT, obj2: LispT): LispT =
  if objAreTyped(LispCharacter):
    eqReturn(LispCharacter, o1.codepoint == o2.codepoint)

  elif objAreTyped(LispNull):
    eqReturn(LispNull, true)

  elif objAreTyped(LispSymbol):
    eqReturn(LispSymbol, o1.name == o2.name)

  else:
    return b2lb(false)

when isMainModule:
  # echo write(eq(LispCharacter(codepoint: ord('\x1F4A9')), LispCharacter(codepoint: ord('\x1F4A9'))))
  echo ord('π')
