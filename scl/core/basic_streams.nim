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

proc peekChar(peekType: LispT,
              inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  if streams.atEnd(nil):
    if eofErrorP:
      raise newException(Exception, "end-of-stream")
    else:
      return eofErrorValue

proc readChar(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  if streams.atEnd(nil):
    if eofErrorP:
      raise newException(Exception, "end-of-stream")
    else:
      return eofErrorValue

proc readCharNoHang(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  discard

proc unreadChar(ch: LispCharacter,
                inputStream: LispInputStream): LispNull =
  discard

proc readLine(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispT =
  discard
