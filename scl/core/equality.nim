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

# macro eqMacro(t: untyped, eqexp: untyped): typed =
#   var source = ""
#   source &= "var o1 = cast[" & t & "](obj1)\n"
#   source &= "var o2 = cast[" & t & "](obj2)\n"
#   source &= "return " & eqexp & "\n"
#   return macros.parseStmt(source)

proc eq(obj1: LispT, obj2: LispT): LispT =
  if objAreTyped(LispCharacter):
    var
      ch1 = cast[LispCharacter](obj1)
      ch2 = cast[LispCharacter](obj2)
    return b2lb(ch1.codepoint == ch2.codepoint)

  elif objAreTyped(LispNull):
    return b2lb(true)

  elif objAreTyped(LispSymbol):
    var
      s1 = cast[LispSymbol](obj1)
      s2 = cast[LispSymbol](obj2)
    return b2lb(s1.name == s2.name)

  else:
    return b2lb(false)

when isMainModule:
  echo write(eq(LispSymbol(name: "hoge"), LispSymbol(name: "hoge")))
