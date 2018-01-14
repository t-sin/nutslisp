import math
import sequtils

import objects
import utf8


type
  StreamEOF = bool
  StreamBufferIndex = int32
  StreamBufferArrayIndex = int32
  StreamPos = ref object
    aidx: StreamBufferArrayIndex
    bidx: StreamBufferIndex

const
  DefaultStreamBufferSize: StreamBufferIndex = 1024

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
    head: StreamPos
    tail: StreamPos

  LispInputStream*[T] = ref object of LispStream[T]
    unreadable: bool
  LispCharacterInputStream* = ref object of LispInputStream[LispCodepoint]
  LispBinaryInputStream* = ref object of LispInputStream[char]

  LispOutputStream*[T] = ref object of LispStream[T]
  LispCharacterOutputStream* = ref object of LispOutputStream[LispCodepoint]
  LispBinaryOutputStream* = ref object of LispOutputStream[char]


proc toBuffer[T](src: seq[T],
                 bufSize: StreamBufferIndex,
                 offset: StreamBufferIndex): seq[T] =
  result = newSeq[T](bufSize)

  var length: StreamBufferIndex
  if src.len - offset > bufSize:
    length = bufSize
  else:
    length = StreamBufferIndex(src.len - offset)

  for i in 0..<length:
    result[i] = src[offset+i]

proc makeAndCopySeq[T](src: seq[T],
                       bufSize: StreamBufferIndex): seq[seq[T]]  =
  var bufNum: StreamBufferArrayIndex
  if src.len == 0:
    bufNum = 1
  elif src.len == bufSize:
    bufNum = StreamBufferArrayIndex(src.len / bufSize + 1)
  else:
    bufNum = StreamBufferArrayIndex(math.ceil(src.len / bufSize))

  result = newSeq[seq[T]](bufNum)
  for i in 0..<bufNum:
    result[i] = toBuffer(src, bufSize, i * bufSize)

template assertPos(stream: untyped): untyped =
  assert(stream.head.aidx >= 0)
  assert(stream.head.aidx < stream.buffer.len)
  assert(stream.tail.aidx >= 0)
  assert(stream.tail.aidx < stream.buffer.len)
  assert(stream.head.bidx >= 0)
  assert(stream.head.bidx < stream.bufferSize)
  assert(stream.tail.bidx >= 0)
  assert(stream.tail.bidx < stream.bufferSize)

proc makeLispCharacterInputStream*(bufSize: StreamBufferIndex,
                                   str: seq[LispCodepoint] = nil): LispCharacterInputStream =
  assert(bufSize > 0)

  let stream = makeLispObject[LispCharacterInputStream]()
  stream.elementType = StreamElementType.setCharacter
  stream.direction = StreamDirectionType.sdtInput
  stream.unreadable = false
  stream.bufferSize = bufSize

  if isNil(str):
    stream.buffer = makeAndCopySeq[LispCodepoint](@[], bufSize)
    stream.head = StreamPos(aidx: 0, bidx: 0)
    stream.tail = StreamPos(aidx: 0, bidx: 0)
  else:
    stream.buffer = makeAndCopySeq(str, bufSize)
    stream.head = StreamPos(aidx: StreamBufferArrayIndex(str.len / bufSize),
                            bidx: StreamBufferindex(str.len mod bufSize))
    stream.tail = StreamPos(aidx: 0, bidx: 0)

  return stream

proc internal_close*[T](stream: LispInputStream[T]): bool =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  elif isNil(stream.buffer):
    return false
  else:
    stream.buffer = nil
    stream.head = nil
    stream.tail = nil
    return true

proc internal_listen*[T](stream: LispInputStream[T]): bool =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  if stream.tail.aidx < stream.head.aidx:
    return true
  elif stream.tail.aidx == stream.head.aidx:
    return stream.tail.bidx < stream.head.bidx
  else:
    return false

proc internal_readElem*[T](stream: LispInputStream[T],
                           peek: bool): (T, StreamEOF) =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  if isNil(stream.buffer):
    return (0'i64, true)

  assertPos(stream)
  if (stream.tail.aidx == stream.head.aidx and
      stream.tail.bidx == stream.head.bidx):
    return (0'i64, true)
  else:
    let elem = stream.buffer[stream.tail.aidx][stream.tail.bidx]

    if not peek:
      if stream.tail.bidx + 1 >= stream.bufferSize:
        stream.tail.aidx += 1
        stream.tail.bidx = (stream.tail.bidx + 1) mod stream.bufferSize
        # TODO: free buffer
      else:
        stream.tail.bidx += 1
      stream.unreadable = true
    return (elem, false)

proc internal_writeElem*[T](stream: LispInputStream[T],
                            elem: T): bool =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  if isNil(stream.buffer):
    return false

  assertPos(stream)
  stream.buffer[stream.head.aidx][stream.head.bidx] = elem

  if stream.head.bidx + 1 >= stream.bufferSize:
    stream.buffer.add(newSeq[T](stream.bufferSize))
    stream.head.aidx += 1
    stream.head.bidx = 0

  else:
    stream.head.bidx += 1

  return true

proc prevPos(pos: StreamPos,
             bufSize: StreamBufferIndex): StreamPos =
  if pos.bidx == 0:
    return StreamPos(aidx: pos.aidx - 1,
                     bidx: bufSize - 1)
  else:
    return StreamPos(aidx: pos.aidx,
                     bidx: pos.bidx - 1)

proc internal_unreadElem*[T](stream: LispInputStream[T],
                             elm: T): bool =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  if isNil(stream.buffer):
    return false

  assertPos(stream)
  if stream.unreadable:
    let prevPos = prevPos(stream.tail, stream.bufferSize)

    if prevPos.aidx < 0 or prevPos.bidx < 0:
      return false
    elif ((prevPos.aidx != stream.head.aidx or
           prevPos.bidx != stream.head.bidx) and
          stream.buffer[prevPos.aidx][prevPos.bidx] == elm):
      stream.unreadable = false
      stream.tail = prevPos
      return true

  return false

proc internal_clearInput*[T](stream: LispInputStream[T]) =
  if isNil(stream):
    raise newException(Exception, "stream is nil!")

  stream.unreadable = false
  stream.tail = stream.head