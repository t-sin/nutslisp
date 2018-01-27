import sequtils
import unittest

import nutslisppkg.nl.objects
import nutslisppkg.nl.utf8
import nutslisppkg.nl.nl_streams


proc ch(ch: char): LispCodepoint =
  return LispCodepoint(ord(ch))

proc str2cp(str: string): seq[LispCodepoint] =
  return toSeq(decodeBytes(str))

suite "stream construction":
  test "can make input stream":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)
    require(not isNil(s))
    check:
      s.direction == StreamDirectionType.sdtInput
      s.elementType == StreamElementType.setCharacter
      nl_listen(s) == false

  test "zero-length buffer":
    expect Exception:
      let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 0)

    let
      str = str2cp("")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    check(false == nl_listen(s))

  test "negative-length buffer":
    expect Exception:
      let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, -1)

  test "initial contents less than buffer length":
    let
      str = str2cp("abc")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      nl_listen(s) == false

  test "initial contents which has length of the buffer":
    let
      str = str2cp("abcd")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      nl_listen(s) == false

  test "initial contents more than buffer length":
    let
      str = str2cp("abcde")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      nl_listen(s) == false

  test "more initial contents":
    let
      str = str2cp("abcdefghi")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    require(not isNil(s))
    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      (ch('f'), false) == nl_readElem(s, false)
      (ch('g'), false) == nl_readElem(s, false)
      (ch('h'), false) == nl_readElem(s, false)
      (ch('i'), false) == nl_readElem(s, false)
      nl_listen(s) == false

suite "close Lisp streams":
  test "Lisp streams construction":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)
    check:
      not isNil(s)
    check(true == nl_close(s))
    check:
      not isNil(s)
    check(false == nl_close(s))

  test "close nil stream":
    let s: LispStream[LispCodepoint] = nil
    expect Exception:
      discard nl_close(s)

suite "check if buffer is available":
  test "zero length buffer":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)
    check:
      false == nl_listen(s)

  test "buffer length 1":
    let
      str = str2cp("a")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    check:
      true == nl_listen(s)
      (ch('a'), false) == nl_readElem(s, false)
      false == nl_listen(s)

  test "buffer array length 2":
    let
      str = str2cp("abcde")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    check:
      true == nl_listen(s)
      (ch('a'), false) == nl_readElem(s, false)
      true == nl_listen(s)
      (ch('b'), false) == nl_readElem(s, false)
      true == nl_listen(s)
      (ch('c'), false) == nl_readElem(s, false)
      true == nl_listen(s)
      (ch('d'), false) == nl_readElem(s, false)
      true == nl_listen(s)
      (ch('e'), false) == nl_readElem(s, false)
      false == nl_listen(s)

  test "simple writing":
    let
      str = str2cp("")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    check:
      false == nl_listen(s)
      true == nl_writeElem(s, ch('a'))
      true == nl_listen(s)
      true == nl_writeElem(s, ch('b'))
      true == nl_listen(s)
      (ch('a'), false) == nl_readElem(s, false)
      true == nl_listen(s)
      (ch('b'), false) == nl_readElem(s, false)
      false == nl_listen(s)

suite "read element for nl":
  test "return EOF true and 0 when elements exists in buffer":
    var s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)
    check((ch('\x0'), true) == nl_readElem(s, false))

    let str = str2cp("")
    s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)
    check((ch('\x0'), true) == nl_readElem(s, false))

  test "return EOF true and 0 when nil stream":
    let s: LispStream[LispCodepoint] = nil
    expect Exception:
      check((ch('\x0'), true) == nl_readElem(s, false))
    expect Exception:
      check((ch('\x0'), true) == nl_readElem(s, true))

  test "read initial contents":
    let
      str = str2cp("abcde")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      (ch('\x0'), true) == nl_readElem(s, false)

  test "read and peek initial contents":
    let
      str = str2cp("abcde")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      (ch('a'), false) == nl_readElem(s, true)
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)

      (ch('d'), false) == nl_readElem(s, true)
      (ch('d'), false) == nl_readElem(s, true)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      (ch('\x0'), true) == nl_readElem(s, false)

  test "read contents that wrote":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)
    discard nl_writeElem(s, ch('a'))
    discard nl_writeElem(s, ch('b'))
    discard nl_writeElem(s, ch('c'))
    discard nl_writeElem(s, ch('d'))
    discard nl_writeElem(s, ch('e'))

    check:
      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      (ch('\x0'), true) == nl_readElem(s, false)

  test "read and write alternately":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check((ch('\x0'), true) == nl_readElem(s, false))

    discard nl_writeElem(s, ch('a'))
    check((ch('a'), false) == nl_readElem(s, false))
    check((ch('\x0'), true) == nl_readElem(s, false))

    discard nl_writeElem(s, ch('b'))
    check((ch('b'), false) == nl_readElem(s, false))
    check((ch('\x0'), true) == nl_readElem(s, false))

    discard nl_writeElem(s, ch('c'))
    check((ch('c'), false) == nl_readElem(s, false))
    check((ch('\x0'), true) == nl_readElem(s, false))

    discard nl_writeElem(s, ch('d'))
    check((ch('d'), false) == nl_readElem(s, false))
    check((ch('\x0'), true) == nl_readElem(s, false))

    discard nl_writeElem(s, ch('e'))
    check((ch('e'), false) == nl_readElem(s, false))
    check((ch('\x0'), true) == nl_readElem(s, false))

suite "write element for nl":
  test "write to empty stream":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check:
      true == nl_writeElem(s, ch('a'))
      (ch('a'), false) == nl_readElem(s, false)

  test "write to stream which has initial contents":
    let
      str = str2cp("ab")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      true == nl_writeElem(s, ch('c'))

      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('\x0'), true) == nl_readElem(s, false)

  test "write over buffer array":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check:
      true == nl_writeElem(s, ch('a'))
      true == nl_writeElem(s, ch('b'))
      true == nl_writeElem(s, ch('c'))
      true == nl_writeElem(s, ch('d'))
      true == nl_writeElem(s, ch('e'))

      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      (ch('d'), false) == nl_readElem(s, false)
      (ch('e'), false) == nl_readElem(s, false)
      (ch('\x0'), true) == nl_readElem(s, false)

suite "unread element for nl":
  test "unread to empty stream":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check:
      false == nl_unreadElem(s, ch('a'))

  test "unread to nil":
    let s: LispStream[LispCodepoint] = nil

    expect Exception:
      discard nl_unreadElem(s, ch('a'))

  test "unread to closed stream":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    discard nl_close(s)
    check:
      false == nl_unreadElem(s, ch('a'))

  test "unread element with non-read stream":
    let
      str = str2cp("abc")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      false == nl_unreadElem(s, ch('a'))

  test "unread element":
    let
      str = str2cp("abc")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      (ch('a'), false) == nl_readElem(s, false)
      true == nl_unreadElem(s, ch('a'))
      true == nl_listen(s)

  test "unread element repeatedly":
    let
      str = str2cp("abc")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check:
      (ch('a'), false) == nl_readElem(s, false)
      true == nl_unreadElem(s, ch('a'))

      (ch('a'), false) == nl_readElem(s, false)
      (ch('b'), false) == nl_readElem(s, false)
      (ch('c'), false) == nl_readElem(s, false)
      true == nl_unreadElem(s, ch('c'))

      (ch('c'), false) == nl_readElem(s, false)

      # End of buffer
      false == nl_listen(s)

      true == nl_unreadElem(s, ch('c'))
      true == nl_listen(s)

      (ch('c'), false) == nl_readElem(s, false)
      false == nl_listen(s)

suite "clear input":
  test "operation to nil stream":
    let s: LispStream[LispCodepoint] = nil
    expect Exception:
      nl_clearInput(s)

  test "operation to clear buffer":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check(false == nl_listen(s))
    nl_clearInput(s)
    check(false == nl_listen(s))

  test "clear initial contents":
    let
      str = str2cp("abc")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check(true == nl_listen(s))
    nl_clearInput(s)
    check(false == nl_listen(s))

  test "clear written contents":
    let s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4)

    check(false == nl_listen(s))

    discard nl_writeElem(s, ch('a'))
    check(true == nl_listen(s))
    nl_clearInput(s)
    check(false == nl_listen(s))

  test "clear contents over length of buffer":
    let
      str =str2cp("abcde")
      s = makeLispStream[LispCodepoint](setCharacter, sdtInput, 4, str)

    check(true == nl_listen(s))
    nl_clearInput(s)
    check(false == nl_listen(s))
