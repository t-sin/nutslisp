import sequtils

import objects
import utf8


const
  StreamBufferSize: int32 = 1024

type
  StreamDirectionType* = enum
    sdtInput, sdtOutput, stdInputOutput
  StreamElementType* = enum
    setCharacter, setBinary
  StreamEOF* = bool
  StreamBufferIndex = int32

  LispStream*[T] = ref object of LispT
    direction*: StreamDirectionType
    elementType*: StreamElementType
    buffer: seq[T]
    currentPos: StreamBufferIndex
    bufferPos: StreamBufferIndex

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
  stream.unreadable = false
  if isNil(str):
    stream.buffer = newSeqWith(StreamBufferSize, LispCodepoint(0))
    stream.currentPos = 0
    stream.bufferPos = 0
  else:
    stream.buffer = newSeqWith(StreamBufferSize, LispCodepoint(0))
    for i in 0..<str.len:
      stream.buffer[i] = str[i]
    stream.currentPos = 0
    stream.bufferPos = StreamBufferIndex(str.len - 1)

  return stream

proc internal_listen[T](stream: LispInputStream[T]): bool =
  if not stream.currentPos == stream.bufferPos:
    return true
  else:
    return false

proc internal_readElem[T](stream: LispInputStream[T],
                          peek: bool): (T, StreamEOF) =
  if isNil(stream.buffer):
    return (0'i64, true)
  if stream.currentPos == stream.bufferPos:
    return (0'i64, false)
  else:
    var elm = stream.buffer[stream.currentPos]
    if not peek:
      stream.currentPos = (stream.currentPos + 1) mod StreamBufferSize
      stream.unreadable = true
    return (elm, false)

proc internal_writeElem[T](stream: LispInputStream[T],
                           elm: T): bool =
  if isNil(stream.buffer):
    return false
  elif (stream.currentPos + 1) mod StreamBufferSize == stream.bufferPos:
    return false
  else:
    stream.currentPos = (stream.currentPos + 1) mod StreamBufferSize
    stream.buffer[stream.currentPos] = elm
    return true

proc prevPos(pos: StreamBufferIndex): StreamBufferIndex =
  if pos == 0:
    return StreamBufferSize
  else:
    return pos - 1

proc internal_unreadElem[T](stream: LispInputStream[T],
                            elm: T): bool =
  if isNil(stream.buffer):
    return false
  elif stream.unreadable:
    var prevPos = prevPos(stream.currentPos)
    if prevPos != stream.bufferPos and stream.buffer[prevPos] == elm:
      stream.unreadable = false
      stream.currentPos = prevPos
      return true

  return false

proc internal_clearInput[T](stream: LispInputStream[T]) =
  stream.unreadable = false
  stream.bufferPos = stream.currentPos mod StreamBufferSize


when isMainModule:
  var s = makeLispCharacterInputStream(sequtils.toSeq(decodeBytes("あいうえおか")))

  proc readPrint[T](stream: LispInputStream[T]): LispCodepoint =
    var
      ch: LispCodepoint
      eof: StreamEOF
    (ch, eof) = internal_readElem(s, false)
    if eof:
      echo "(ch, eof): (_, true)"
    else:
      echo "(ch, eof): (" & $(encodeCodepoint(ch)) & ", " & $(eof) & ")"
    return ch

  var
    ch: LispCodepoint
    eof: StreamEOF

  (ch, eof) = internal_readElem(s, true)
  echo encodeCodepoint(ch) # a
  echo internal_unreadElem(s, decodeByte("あ"))

  ch = readPrint(s) # a

  ch = readPrint(s) # i
  echo internal_unreadElem(s, decodeByte("い")) # true

  ch = readPrint(s) # i

  internal_clearInput(s)
  ch = readPrint(s) # u

  ch = readPrint(s) # e

  echo internal_unreadElem(s, decodeByte("う")) # false
  ch = readPrint(s) # o
