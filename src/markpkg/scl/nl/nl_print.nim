import strutils

import objects

proc write*(obj: LispT): string =
  assert(not isNil(obj))

  if obj of LispNull:
    return "nil"

  elif obj of LispCharacter:
    var ch = LispCharacter(obj)
    return $(chr(ch.codepoint))

  elif obj of LispSymbol:
    var s = obj.LispSymbol
    return s.name

  elif obj of LispList:
    proc write_list(obj: LispT): string =
      if obj of LispNull:
        return ""
      else:
        var
          lis = LispList(obj)
          cdrstr = write_list(lis.cdr)
        if cdrstr.len == 0:
           return write(lis.car)
        else:
          return write(lis.car) & " " & cdrstr

    return "($list)".format("list", write_list(obj))

  elif obj of LispFunction:
    let fn = LispFunction(obj)

    if fn.nativeP:
      return "#<function native $id>".format("id", fn.id)
    else:
      return "#<function lisp (lambda $args $body)>".format(
        "args", write(fn.lambdaList), "body", write(fn.body))

  elif obj of LispCons:
    var c = LispCons(obj)
    return "($car . $cdr)".format(
      "car", write(c.car), "cdr", write(c.cdr))

  else:
    return "t"
