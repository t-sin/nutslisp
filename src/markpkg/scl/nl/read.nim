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
    firstP = true
    list: LispList
    tail: LispList

  while true:
    (cp, eof) = internal_readElem(s, true)

    if cp != ord(')'):
      let cons = makeLispObject[LispList]()
      if firstP:
        list = cons
        firstP = false
      else:
        tail.cdr = cons
      tail = cons

    if eof:
      raise newException(Exception, "read error while parsing through in list")

    elif cp == ord(')'):
      discard internal_readElem(s, false)
      tail.cdr = makeLispObject[LispNull]()
      return list

    else:
      tail.car = nl_read(s)

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
