import streams

import objects


type
  LispStream* = ref object of LispT
  LispInputStream* = ref object of LispStream
  LispOutputStream* = ref object of LispStream


proc peekChar(peekType: LispT,
              inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispCharacter =
  discard

proc readChar(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispCharacter =
  discard

proc readCharNoHang(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispCharacter =
  discard

proc unreadChar(ch: LispCharacter,
                inputStream: LispInputStream): LispNull =
  discard

proc readLine(inputStream: LispInputStream,
              eofErrorP: bool,
              eofErrorValue: LispT,
              recursiveP: bool): LispCharacter =
  discard
