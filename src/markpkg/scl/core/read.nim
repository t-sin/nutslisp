import objects
import basic_streams
import readtable
import runtime


proc readDelimitedList(ch: LispCharacter,
                       inputStream: LispInputStream,
                       recursiveP: bool): LispList =
  discard

proc readPreservingWhitespace(inputStream: LispinputStream,
                              eofErrorP: bool,
                              eofErrorValue: LispT,
                              recursiveP: bool): LispCharacter =
  discard

proc read(inputStream: LispinputStream,
          eofErrorP: bool,
          eofErrorValue: LispT,
          recursiveP: bool): LispCharacter =
  discard

proc readFromString(str: string)
