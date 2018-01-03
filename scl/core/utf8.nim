import objects

## decoding UTF-8 bytes (string of Nim) into Unicode codepoint
## cf. https://github.com/t-sin/oji/blob/master/encoding/unicode/utf-8.lisp

proc isAscii(ch: char): bool =
  return ord(ch) < 0x80

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

proc decodeCharseq(chars: string): LispCodepoint =
  case chars.len
  of 1:
    return 0b01111111 and ord(chars[0])
  of 2:
    return (`shl`(0b0001111 and ord(chars[0]), 6) or
            0b00111111 and ord(chars[1]))
  of 3:
    return (`shl`(0b00001111 and ord(chars[0]), 12) or
            `shl`(0b00111111 and ord(chars[1]), 6) or
            0b00111111 and ord(chars[2]))
  of 4:
    return (`shl`(0b00000111 and ord(chars[0]), 18) or
            `shl`(0b00111111 and ord(chars[1]), 12) or
            `shl`(0b00111111 and ord(chars[2]), 6) or
            0b00111111 and ord(chars[3]))
  else:
    raise newException(Exception, "malformed utf-8 chars")

iterator decodeBytes(bytes: string): LispCodepoint =
  var idx = 0
  while idx < bytes.len:
    var ch = bytes[idx]
    if isAscii(ch):
      yield ord(ch)
      idx += 1
    elif isCharseqStart(ch):
      var
        seqlen = charseqLength(ch)
        codepoint = decodeCharseq(bytes[idx..<idx+seqlen])
      yield codepoint
      idx += seqlen
    else:
      raise newException(Exception, "invalid utf-8 byte")


when isMainModule:
  var s = "あぁいぃうぅぅ"
  echo s.len
  for ch in decodeBytes(s):
    echo ch
