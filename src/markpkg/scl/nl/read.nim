import objects
import basic_streams
import print


proc readParenthesis(s: LispCharacterInputStream): LispT =
  return makeLispObject[LispNull]()

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
  let s = makeLispCharacterInputStream(64)

  echo print.write(readParenthesis(s))
