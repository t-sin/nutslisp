import streams

import objects


const
  StreamBufferSize: int32 = 1024

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


proc makeLispCharacterInputStream(str: seq[LispCodepoint] = nil): LispCharacterInputStream =
  var stream = makeLispObject[LispCharacterInputStream]()
  stream.elementType = StreamElementType.setCharacter
  stream.direction = StreamDirectionType.sdtInput
  if isNil(str):
    stream.buffer = newSeqWith(StreamBufferSize, LispCodepoint(0))
    stream.currentPos = 0
    stream.bufferPos = 0
    stream.unreadable = false
  else:
    stream.buffer = newSeqWith(StreamBufferSize, LispCodepoint(0))
    for i in 0..<str.len:
      stream.buffer[i] = str[i]
    stream.currentPos = 0
    stream.bufferPos = int32(str.len)
    stream.unreadable = true
  return stream

proc internal_isEOF[T](stream: LispInputStream[T]): bool =
  if stream.currentPos == stream.bufferPos or stream.currentPos == stream.buffer.len:
    return true
  else:
    return false

proc internal_readChar[T](stream: LispInputStream[T],
                          peek: bool): (T, StreamEOF) =
  if internal_isEOF(stream):
    return (0'i64, true)
  else:
    var elm = stream.buffer[stream.currentPos]
    if not peek:
      stream.currentPos = (stream.currentPos + 1) mod StreamBufferSize
    return (elm, false)

proc internal_writeChar[T](stream: LispInputStream[T],
                           elm: T): bool =
  if (stream.currentPos + 1) mod StreamBufferSize == stream.bufferPos:
    return false
  else:
    stream.currentPos = (stream.currentPos + 1) mod StreamBufferSize
    stream.buffer[stream.currentPos] = elm
    return true


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
