import streams

import objects


type
  StreamDirectionType* = enum
    sdtInput, sdtOutput, stdInputOutput
  StreamElementType* = enum
    setCharacter, setBinary

  LispStream* = ref object of LispT
    direction*: StreamDirectionType
    elementType*: StreamElementType
    stream: Stream

  LispInputStream* = ref object of LispStream
    unreadable: bool
  LispOutputStream* = ref object of LispStream


proc newLispInputStream(str: string = ""): LispInputStream =
  var stream = makeLispObject[LispInputStream]()
  stream.direction = StreamDirectionType.sdtInput
  stream.elementType = StreamElementType.setCharacter
  stream.stream = newStringStream(str)
  if str.len > 0:
    stream.unreadable = true
  else:
    stream.unreadable = false

  return stream

# decoding UTF-8 bytes into codepoint
# https://github.com/t-sin/oji/blob/master/encoding/unicode/utf-8.lisp
proc isCharseqStart(ch: char): bool =
  return 0b11000000 == (0b11000000 and ord(ch))

proc charseqLength(ch: char): int =
  var
    count = 0
    target = 0b11110000 and ord(ch)
    bitmask = 0b10000000
  while bitmask >= 0b00010000 and ((target and bitmask) != 0):
    count += 1
    target = target shl 1
  return count

proc decodeUtf8Char(inputStream: LispInputStream): LispCharacter =
  discard

proc streamPeekChar(peekType: LispT,
              inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  if streams.atEnd(inputStream.stream):
    if eofErrorP:
      raise newException(Exception, "end-of-stream")
    else:
      return eofErrorValue
  else:
    var ch = makeLispObject[LispCharacter]()
    ch.codepoint = ord(peekChar(inputStream.stream))
    return ch

proc streamReadChar(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  if streams.atEnd(nil):
    if eofErrorP:
      raise newException(Exception, "end-of-stream")
    else:
      return eofErrorValue

proc streamReadCharNoHang(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  discard

proc streamUnreadChar(ch: LispCharacter,
                inputStream: LispInputStream): LispNull =
  discard

proc streamReadLine(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  discard

when isMainModule:
  var
    stream = newLispInputStream("漢")
    ch = streamPeekChar(LispNull(), stream, false, LispT(), false)
  echo LispCharacter(ch).codepoint
