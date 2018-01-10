import sequtils
import unittest

import scl.core.objects
import scl.core.utf8
import scl.core.basic_streams


proc ch(ch: char): LispCodepoint =
  return LispCodepoint(ord(ch))

proc str2cp(str: string): seq[LispCodepoint] =
  return toSeq(decodeBytes(str))

suite "stream construction":
  test "can make input stream":
    let s = makeLispCharacterInputStream(4)
    require(not isNil(s))
    check:
      s.direction == StreamDirectionType.sdtInput
      s.elementType == StreamElementType.setCharacter
      internal_listen(s) == false

  test "zero-length buffer":
    expect Exception:
      let s = makeLispCharacterInputStream(0)

    let
      str = str2cp("")
      s = makeLispCharacterInputStream(4, str)
    check(false == internal_listen(s))

  test "negative-length buffer":
    expect Exception:
      let s = makeLispCharacterInputStream(-1)

  test "initial contents less than buffer length":
    let
      str = str2cp("abc")
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == internal_readElem(s, false)
      (ch('b'), false) == internal_readElem(s, false)
      (ch('c'), false) == internal_readElem(s, false)
      internal_listen(s) == false

  test "initial contents which has length of the buffer":
    let
      str = str2cp("abcd")
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == internal_readElem(s, false)
      (ch('b'), false) == internal_readElem(s, false)
      (ch('c'), false) == internal_readElem(s, false)
      (ch('d'), false) == internal_readElem(s, false)
      internal_listen(s) == false

  test "initial contents more than buffer length":
    let
      str = str2cp("abcde")
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == internal_readElem(s, false)
      (ch('b'), false) == internal_readElem(s, false)
      (ch('c'), false) == internal_readElem(s, false)
      (ch('d'), false) == internal_readElem(s, false)
      (ch('e'), false) == internal_readElem(s, false)
      internal_listen(s) == false

  test "more initial contents":
    let
      str = str2cp("abcdefghi")
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == internal_readElem(s, false)
      (ch('b'), false) == internal_readElem(s, false)
      (ch('c'), false) == internal_readElem(s, false)
      (ch('d'), false) == internal_readElem(s, false)
      (ch('e'), false) == internal_readElem(s, false)
      (ch('f'), false) == internal_readElem(s, false)
      (ch('g'), false) == internal_readElem(s, false)
      (ch('h'), false) == internal_readElem(s, false)
      (ch('i'), false) == internal_readElem(s, false)
      internal_listen(s) == false

suite "close Lisp streams":
  test "Lisp streams construction":
    let s = makeLispCharacterInputStream(4)
    check:
      not isNil(s)
    check(true == internal_close(s))
    check:
      not isNil(s)
    check(false == internal_close(s))

  test "close nil stream":
    let s: LispCharacterInputStream = nil
    check(false ==  internal_close(s))

suite "check if buffer is available":
  test "zero length buffer":
    let s = makeLispCharacterInputStream(4)
    check:
      false == internal_listen(s)

  test "buffer length 1":
    let
      str = str2cp("a")
      s = makeLispCharacterInputStream(4, str)
    check:
      true == internal_listen(s)
      (ch('a'), false) == internal_readElem(s, false)
      false == internal_listen(s)

  test "buffer array length 2":
    let
      str = str2cp("abcde")
      s = makeLispCharacterInputStream(4, str)
    check:
      true == internal_listen(s)
      (ch('a'), false) == internal_readElem(s, false)
      true == internal_listen(s)
      (ch('b'), false) == internal_readElem(s, false)
      true == internal_listen(s)
      (ch('c'), false) == internal_readElem(s, false)
      true == internal_listen(s)
      (ch('d'), false) == internal_readElem(s, false)
      true == internal_listen(s)
      (ch('e'), false) == internal_readElem(s, false)
      false == internal_listen(s)

  test "write to buffer":
    let
      str = str2cp("")
      s = makeLispCharacterInputStream(4, str)
    check:
      false == internal_listen(s)
      true == internal_writeElem(s, ch('a'))
      true == internal_listen(s)
      true == internal_writeElem(s, ch('b'))
      true == internal_listen(s)
      (ch('a'), false) == internal_readElem(s, false)
      true == internal_listen(s)
      (ch('b'), false) == internal_readElem(s, false)
      false == internal_listen(s)
