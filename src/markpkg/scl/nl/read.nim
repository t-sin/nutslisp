import sequtils

import objects
import basic_streams
import print
import utf8


template cp(ch: untyped): untyped =
  LispCodepoint(ord(ch))

const nl_whitespace = @[cp(' '), cp('\t'), cp('\r'), cp('\l')]
const nl_terminate_macro = @[cp(')')]

proc nl_read*(s: LispCharacterInputStream): LispT

proc skip(chs: seq[LispCodepoint],
          s: LispCharacterInputStream) =
  var
    cp: LispCodepoint
    eof: bool

  while true:
    (cp, eof) = internal_readElem(s, true)

    if cp in chs:
      discard internal_readElem(s, false)

    else:
      break

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
  var
    name = ""
    cp: LispCodepoint
    eof: bool

  while true:
    (cp, eof) = internal_readElem(s, true)

    if eof or cp in nl_whitespace or cp in nl_terminate_macro:
      if cp in nl_whitespace:
        discard internal_readElem(s, false)

      if name.len <= 0:
        return makeLispObject[LispNull]()

      else:
        let sym = makeLispObject[LispSymbol]()
        sym.name = name
        return sym

    else:
      discard internal_readElem(s, false)
      name.add(encodeCodepoint(cp))

proc nl_read*(s: LispCharacterInputStream): LispT =
  var
    cp: LispCodepoint
    eof: bool

  skip(nl_whitespace, s)

  (cp, eof) = internal_readElem(s, true)

  if eof:
    return makeLispObject[LispNull]()

  case cp
  of ord('('):
    discard internal_readElem(s, false)
    return readParenthesis(s)

  else:
    return readConstituent(s)

when isMainModule:
  let s = makeLispCharacterInputStream(64, toSeq(decodeBytes("(a (b) c)")))
  let sexp = nl_read(s)

  echo write(sexp)

