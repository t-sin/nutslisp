import sequtils

import objects
import basic_streams
import print
import utf8


proc nl_read*(s: LispCharacterInputStream): LispT

proc readParenthesis(s: LispCharacterInputStream): LispT =
  var
    cp: LispCodepoint
    eof: bool
    list = makeLispObject[LispList]()
    tail = list

  while true:
    (cp, eof) = internal_readElem(s, false)

    if eof:
      raise newException(Exception, "read error while parsing through in list")

    elif cp == ord(')'):
      tail.cdr = makeLispObject[LispNull]()
      return list

    else:
      let val = nl_read(s)
      tail.car = val
      tail.cdr = makeLispObject[LispList]()
      tail = LispList(tail.cdr)

proc readConstituent(s: LispCharacterInputStream): LispT =
  discard

proc nl_read*(s: LispCharacterInputStream): LispT =
  var
    cp: LispCodepoint
    eof: bool

  (cp, eof) = internal_readElem(s, false)

  if eof:
    return makeLispObject[LispNull]()

  case cp
  of ord('('):
    return readParenthesis(s)

  else:
    return makeLispObject[LispNull]()

when isMainModule:
  let s = makeLispCharacterInputStream(64, toSeq(decodeBytes("(a)")))

  echo write(nl_read(s))
