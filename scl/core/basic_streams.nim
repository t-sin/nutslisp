import streams

import objects


type
  StreamDirectionType* = enum
    sdtInput, sdtOutput, stdInputOutput
  StreamElementType* = enum
    setCharacter, setBinary
  StreamEOF* = bool

  LispStream*[T] = ref object of LispT
    direction*: StreamDirectionType
    elementType*: StreamElementType
    buffer: seq[T]
    currentPos: int32
    bufferPos: int32

  LispInputStream*[T] = ref object of LispStream[T]
    unreadable: bool
  LispCharacterInputStream* = ref object of LispInputStream[LispCodepoint]
  LispBinaryInputStream* = ref object of LispInputStream[char]

  LispOutputStream*[T] = ref object of LispStream[T]
  LispCharacterOutputStream* = ref object of LispOutputStream[LispCodepoint]
  LispBinaryOutputStream* = ref object of LispOutputStream[char]

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

    raise newException(Exception, "malformed utf-8 chars")

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
