import strutils

import nl_objects

proc print*(obj: LispT): string =
  assert(not isNil(obj))

  if obj of LispNull:
    return "nil"

  if obj of LispInteger:
    let ival = LispInteger(obj)
    return $(ival.value)

  elif obj of LispCharacter:
    let ch = LispCharacter(obj)
    return $(chr(ch.codepoint))

  elif obj of LispVector[LispT]:
    let vec = LispVector[LispT](obj)
    var s = "("

    for elm in vec.content:
      s.add(print(elm))
      s.add(" ")

    s[s.len - 1] = ')'

  elif obj of LispString:
    let str = LispString(obj)
    var s = ""

    for ch in str.content:
      s.add(chr(ch.codepoint))

    return s

  elif obj of LispSymbol:
    let s = obj.LispSymbol
    if s.package.name == "keyword":
      return ":$name".format("name", s.name)
    else:
      return s.name

  elif obj of LispFunction:
    let fn = LispFunction(obj)

    if fn.nativeP:
      return "#<function native $id>".format("id", fn.id)
    else:
      return "#<function lisp (lambda $args $body)>".format(
        "args", print(fn.lambdaList), "body", print(fn.body))

  elif obj of LispCons:
    let c = LispCons(obj)
    proc write_list(obj: LispT): string =
      if obj of LispNull:
        return ""
      else:
        let
          lis = LispCons(obj)
          cdrstr = write_list(lis.cdr)
        if cdrstr.len == 0:
           return print(lis.car)
        else:
          return print(lis.car) & " " & cdrstr

    if c.cdr of LispCons:
      return "($list)".format("list", write_list(obj))

    else:
      return "($car . $cdr)".format(
        "car", print(c.car), "cdr", print(c.cdr))

  else:
    return "t"

