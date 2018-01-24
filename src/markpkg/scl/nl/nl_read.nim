import objects
import nl_streams
import nl_runtime
import utf8


template cp(ch: untyped): untyped =
  LispCodepoint(ord(ch))

const nl_whitespace = @[cp(' '), cp('\t'), cp('\r'), cp('\l')]
const nl_terminate_macro = @[cp(')')]

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

proc readParenthesis(rt: LispRuntime,
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

proc readDoubleQuote(rt: LispRuntime,
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

proc readConstituent(rt: LispRuntime,
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
        return intern(name, rt.currentPackage)[0]

    else:
      discard nl_readElem(s, false)
      name.add(encodeCodepoint(cp))

proc nl_read*(rt: LispRuntime,
              s: LispStream[LispCodepoint]): LispT =
  var
    cp: LispCodepoint
    eof: bool

  skip(nl_whitespace, s)

  (cp, eof) = nl_readElem(s, true)

  if eof:
    return makeLispObject[LispNull]()

  case cp
  of ord('('):
    discard nl_readElem(s, false)
    return readParenthesis(rt, s)

  of ord('"'):
    discard nl_readElem(s, false)
    return readDoubleQuote(rt, s)

  else:
    return readConstituent(rt, s)
