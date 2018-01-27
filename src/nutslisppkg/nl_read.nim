import strutils

import objects
import nl_streams
import nl_runtime
import utf8


template cp(ch: untyped): untyped =
  LispCodepoint(ord(ch))

const nl_whitespace = @[cp(' '), cp('\t'), cp('\r'), cp('\l')]
const nl_terminate_macro = @[cp(')')]
const nl_number = @[cp('0'), cp('1'), cp('2'), cp('3'), cp('4'),
                    cp('5'), cp('6'), cp('7'), cp('8'), cp('9')]

proc nl_read*(rt: LispRuntime,
              s: LispStream[LispCodepoint]): LispT

proc skip(chs: seq[LispCodepoint],
          s: LispStream) =
  var
    cp: LispCodepoint
    eof: bool

  while true:
    (cp, eof) = nl_readElem(s, true)

    if cp in chs:
      discard nl_readElem(s, false)

    else:
      break

proc readList(rt: LispRuntime,
              s: LispStream[LispCodepoint]): LispT =
  var
    cp: LispCodepoint
    eof: bool
    firstP = true
    list: LispList
    tail: LispList

  while true:
    (cp, eof) = nl_readElem(s, true)

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
      discard nl_readElem(s, false)

      if isNil(list):
        return makeLispObject[LispNull]()

      else:
        tail.cdr = makeLispObject[LispNull]()
        return list

    else:
      tail.car = nl_read(rt, s)

proc readString(rt: LispRuntime,
                s: LispStream[LispCodepoint]): LispT =
    var
      cp: LispCodepoint
      eof: bool
      str = makeLispObject[LispString]()

    str.content = @[]

    while true:
      (cp, eof) = nl_readElem(s, true)

      if eof:
        raise newException(Exception, "read error while parsing through string")

      elif cp == ord('"'):
        return str

      else:
        discard nl_readElem(s, false)
        let ch = makeLispObject[LispCharacter]()
        ch.codepoint = cp
        str.content.add(ch)

proc readSymbol(rt: LispRuntime,
                s: LispStream[LispCodepoint]): LispT =
  var
    name = ""
    cp: LispCodepoint
    eof: bool

  while true:
    (cp, eof) = nl_readElem(s, true)

    if eof or cp in nl_whitespace or cp in nl_terminate_macro:
      if cp in nl_whitespace:
        discard nl_readElem(s, false)

      if name.len <= 0:
        return makeLispObject[LispNull]()

      else:
        if name == "t":
          return makeLispObject[LispT]()

        if name == "nil":
          return makeLispObject[LispNull]()

        else:
          return intern(name, rt.currentPackage)[0]

    else:
      discard nl_readElem(s, false)
      name.add(encodeCodepoint(cp))

proc readNumber(rt: LispRuntime,
                s: LispStream[LispCodepoint]): LispT =
  var
    valueStr = ""
    cp: LispCodepoint
    eof: bool

  while true:
    (cp, eof) = nl_readElem(s, true)

    if cp in nl_number:
      discard nl_readElem(s, false)
      valueStr.add(chr(cp))

    elif eof or cp in nl_whitespace or cp in nl_terminate_macro:
      if cp in nl_whitespace:
        discard nl_readElem(s, false)

      assert(valueStr.len > 0)
      let v = makeLispObject[LispInteger]()
      v.value = parseInt(valueStr)
      return v

    else:
      raise newException(Exception, "read error when reading number: invalid integer")

proc nl_read*(rt: LispRuntime,
              s: LispStream[LispCodepoint]): LispT =
  var
    cp: LispCodepoint
    eof: bool

  skip(nl_whitespace, s)

  (cp, eof) = nl_readElem(s, true)

  if eof:
    return makeLispObject[LispNull]()

  elif cp in nl_number:
    return readNumber(rt, s)

  case cp
  of ord('('):
    discard nl_readElem(s, false)
    return readList(rt, s)

  of ord('"'):
    discard nl_readElem(s, false)
    return readString(rt, s)

  else:
    return readSymbol(rt, s)