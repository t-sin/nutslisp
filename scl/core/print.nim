import objects

proc write*(obj: LispT): string =
  if obj of LispNull:
    return "nil"

  elif obj of LispCharacter:
    var ch = cast[LispCharacter](obj)
    return $(chr(ch.codepoint))

  elif obj of LispSymbol:
    var s = cast[LispSymbol](obj)
    return s.name

  elif obj of LispList:
    proc write_list(obj: LispT): string =
      if obj of LispNull:
        return ""
      else:
        var
          lis = cast[LispList](obj)
          cdrstr = write_list(lis.cdr)
        if cdrstr.len == 0:
           return write(lis.car)
        else:
          return write(lis.car) & " " & cdrstr
          
    return "(" & write_list(obj) & ")"

  elif obj of LispCons:
    var c = cast[LispCons](obj)
    return "(" & write(c.car) & " . " & write(c.cdr) & ")"

  else:
    return "t"
