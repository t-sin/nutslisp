import sequtils

import objects
import utf8


const
  DefaultStreamBufferSize: int32 = 1024

type
  StreamEOF = bool
  StreamBufferIndex = int32
  StreamBufferArrayIndex = int32
  StreamPos = object
    aidx: StreamBufferArrayIndex
    bidx: StreamBufferIndex

type
  StreamDirectionType* = enum
    sdtInput, sdtOutput, stdInputOutput
  StreamElementType* = enum
    setCharacter, setBinary

  LispStream*[T] = ref object of LispT
    direction*: StreamDirectionType
    elementType*: StreamElementType
    bufferSize: StreamBufferIndex
    buffer: seq[seq[T]]
    headPos: StreamPos
    tailPos: StreamPos

  LispInputStream*[T] = ref object of LispStream[T]
    unreadable: bool
  LispCharacterInputStream* = ref object of LispInputStream[LispCodepoint]
  LispBinaryInputStream* = ref object of LispInputStream[char]

  LispOutputStream*[T] = ref object of LispStream[T]
  LispCharacterOutputStream* = ref object of LispOutputStream[LispCodepoint]
  LispBinaryOutputStream* = ref object of LispOutputStream[char]


proc toBuffer[T](src: seq[T], offset: StreamBufferIndex): seq[T] =
  result = newSeq[T](DefaultStreamBufferSize)

  var
    length: StreamBufferIndex
  if src.len > DefaultStreamBufferSize:
    length = DefaultStreamBufferSize
  else:
    length = StreamBufferIndex(src.len)

  for i in 0..<length:
    result[i] = src[offset+i]

proc initialBufferNum[T](a: seq[T]): StreamBufferArrayIndex =
  return StreamBufferArrayIndex(a.len / DefaultStreamBufferSize) + 1

proc initialLastBufferPos[T](a: seq[T]): StreamBufferIndex =
  return a.len mod DefaultStreamBufferSize

proc makeAndCopySeq[T](src: seq[T]): seq[seq[T]]  =
  var bufNum = initialBufferNum(src)
  result = newSeq[seq[T]](bufNum)
  for i in 0..<bufNum:
    result[i] = toBuffer(src, i * DefaultStreamBufferSize)

proc makeLispCharacterInputStream(str: seq[LispCodepoint] = nil): LispCharacterInputStream =
  var stream = makeLispObject[LispCharacterInputStream]()
  stream.elementType = StreamElementType.setCharacter
  stream.direction = StreamDirectionType.sdtInput
  stream.unreadable = false

  if isNil(str):
    stream.buffer = makeAndCopySeq[LispCodepoint](@[])
    stream.headPos = StreamPos(aidx: 0, bidx: 0)
    stream.tailPos = StreamPos(aidx: 0, bidx: 0)
  else:
    stream.buffer = makeAndCopySeq(str)
    stream.headPos = StreamPos(aidx: initialBufferNum(str) - 1,
                               bidx: initialLastBufferPos(str))
    stream.tailPos = StreamPos(aidx: 0, bidx: 0)

  return stream

proc internal_close[T](stream: LispInputStream[T]): bool =
  if isNil(stream.buffer):
    return false
  else:
    stream.buffer = nil
    return true

proc internal_listen[T](stream: LispInputStream[T]): bool =
  if stream.tailPos.aidx < stream.headPos.aidx:
    return true
  elif stream.tailPos.aidx == stream.headPos.aidx:
    return stream.tailPos.bidx < stream.headPos.bidx
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
