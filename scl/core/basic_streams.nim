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
