import tables

import objects


proc makeEmptyReadtable*(): LispReadtable =
  var
    syntaxTypeTable = tables.newTable[LispCodepoint, SyntaxType]()
    constTraitTable = tables.newTable[LispCodepoint, ConstituentTraitList]()
    singleMacroTable = tables.newTable[LispCodepoint, proc ()]()
    dispatchMacroTable = tables.newTable[seq[LispCodepoint], proc ()]()
    readtable = LispReadtable(
      syntaxType: syntaxTypeTable,
      constituentTrait: constTraitTable,
      singleMacro: singleMacroTable,
      dispatchMacro: dispatchMacroTable,
      rcase: rcUpcase,
      newlineType: nlLF)

  return readtable

proc addSyntaxToChar*(rt: LispReadtable,
                      cp: LispCodepoint,
                      st: SyntaxType): LispReadtable =
  var syntaxTable = rt.syntaxType
  syntaxTable[cp] = st
  return rt

proc addSyntaxToChar*(rt: LispReadtable,
                      ch: char,
                      st: SyntaxType): LispReadtable =
    return addSyntaxToChar(rt, ord(ch), st)

proc addConstituentTraitToChar*(rt: LispReadtable,
                                cp: LispCodepoint,
                                ctlis: varargs[ConstituentTrait]): LispReadtable =
    var constTraitTable = rt.constituentTrait
    constTraitTable[cp] = @ctlis
    return rt

proc addConstituentTraitToChar*(rt: LispReadtable,
                                ch: char,
                                ctlis: varargs[ConstituentTrait]): LispReadtable =
    return addConstituentTraitToChar(rt, ord(ch), ctlis)

proc makeInitialReadtable*(): LispReadtable =
  var
    rt = makeEmptyReadtable()

  # syntax type
  # NOTE:
  #  constituent characters is a char that does not exist on syntaxType table

  discard addSyntaxToChar(rt, '\t', stWhitespace)
  discard addSyntaxToChar(rt, ord(lcharNewline), stWhitespace)
  discard addSyntaxToChar(rt, '\l', stWhitespace)
  discard addSyntaxToChar(rt, ord(lcharPage), stWhitespace)
  discard addSyntaxToChar(rt, '\r', stWhitespace)
  discard addSyntaxToChar(rt, ' ', stWhitespace)

  discard addSyntaxToChar(rt, '\\', stSingleEscape)
  discard addSyntaxToChar(rt, '|', stMultipleEscape)

  discard addSyntaxToChar(rt, '\"', stTermMacro)
  discard addSyntaxToChar(rt, '#', stNonTermMacro)
  discard addSyntaxToChar(rt, '\'', stTermMacro)
  discard addSyntaxToChar(rt, '(', stTermMacro)
  discard addSyntaxToChar(rt, ')', stTermMacro)
  discard addSyntaxToChar(rt, ',', stTermMacro)
  discard addSyntaxToChar(rt, ';', stTermMacro)
  discard addSyntaxToChar(rt, '`', stTermMacro)

  # constituent traits

  for ch in "!\"#$%&\'()*,;<=>?@[\\]^_`|~{}":
    discard addConstituentTraitToChar(rt, ch, ctAlphabetic)

  for ch in 'a'..'z':
    discard addConstituentTraitToChar(rt, ch, ctAlphabetic, ctDigit)
  for ch in 'A'..'Z':
    discard addConstituentTraitToChar(rt, ch, ctAlphabetic, ctDigit)
  for ch in '0'..'9':
    discard addConstituentTraitToChar(rt, ch, ctAlphabetic, ctDigit)

  discard addConstituentTraitToChar(rt, ':', ctPackageMarker)
  discard addConstituentTraitToChar(rt, '+', ctAlphabetic, ctPlusSign)
  discard addConstituentTraitToChar(rt, '-', ctAlphabetic, ctMinusSign)
  discard addConstituentTraitToChar(rt, '.', ctAlphabetic, ctDot, ctDecimalPoint)
  discard addConstituentTraitToChar(rt, '/', ctAlphabetic, ctRatioMarker)

  discard addConstituentTraitToChar(rt, 'd', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'D', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'e', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'E', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'f', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'F', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'l', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'L', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'd', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'D', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 's', ctAlphabetic, ctDigit, ctExponentMarker)
  discard addConstituentTraitToChar(rt, 'S', ctAlphabetic, ctDigit, ctExponentMarker)

  discard addConstituentTraitToChar(rt, '\x08', ctInvalid)
  discard addConstituentTraitToChar(rt, '\t', ctInvalid)
  discard addConstituentTraitToChar(rt, ord(lcharNewline), ctInvalid)
  discard addConstituentTraitToChar(rt, '\l', ctInvalid)
  discard addConstituentTraitToChar(rt, ord(lcharPage), ctInvalid)
  discard addConstituentTraitToChar(rt, '\r', ctInvalid)
  discard addConstituentTraitToChar(rt, ' ', ctInvalid)
  discard addConstituentTraitToChar(rt, '\x7f', ctInvalid)

  return rt
