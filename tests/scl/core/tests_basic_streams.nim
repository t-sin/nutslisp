import sequtils
import unittest

import scl.core.objects
import scl.core.utf8
import scl.core.basic_streams


proc ch(ch: char, eof: bool): (LispCodepoint, bool) =
  return (LispCodepoint(ord(ch)), eof)

suite "stream construction":
  test "can make input stream":
    let s = makeLispCharacterInputStream(4)
    require(not isNil(s))
    check:
      s.direction == StreamDirectionType.sdtInput
      s.elementType == StreamElementType.setCharacter

  test "zero-length buffer":
    expect Exception:
      let s = makeLispCharacterInputStream(0)

  test "negative-length buffer":
    expect Exception:
      let s = makeLispCharacterInputStream(-1)

  test "initial contents less than buffer length":
    let
      str = toSeq(decodeBytes("abc"))
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      ch('a', false) == internal_readElem(s, false)
      ch('b', false) == internal_readElem(s, false)
      ch('c', false) == internal_readElem(s, false)
      internal_listen(s) == false

  test "initial contents which has length of the buffer":
    let
      str = toSeq(decodeBytes("abcd"))
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      ch('a', false) == internal_readElem(s, false)
      ch('b', false) == internal_readElem(s, false)
      ch('c', false) == internal_readElem(s, false)
      ch('d', true) == internal_readElem(s, false)
      internal_listen(s) == false

  test "initial contents more than buffer length":
    let
      str = toSeq(decodeBytes("abcde"))
      s = makeLispCharacterInputStream(4, str)
    require(not isNil(s))
    check:
      ch('a', false) == internal_readElem(s, false)
      ch('b', false) == internal_readElem(s, false)
      ch('c', false) == internal_readElem(s, false)
      ch('d', true) == internal_readElem(s, false)
      internal_listen(s) == false
