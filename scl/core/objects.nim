import tables


type
  LispObjectId* = uint32
  LispT* = ref object of RootObj
    id*: LispObjectId

var lispObjectCount*: LispObjectId = 0

proc makeLispObject[LispType](): LispType =
  var lispObj = LispType()
  LispT(lispObj).id = lispObjectCount
  lispObjectCount += 1
  return LispType(lispObj)


type
  LispNil* = ref object of LispT

  LispCons* = ref object of LispT
    car*: LispT
    cdr*: LispT
  LispList* = ref object of LispCons

  LispSymbol* = ref object of LispT
    name*: string
    value*: LispT
    function*: LispFunction
    package*: LispPackage
    plist*: LispList

  LispNull* = ref object of LispT

  LispSpecialCharacter* = enum
    lcharNewline = -2
    lcharPage = -1
  LispCodepoint* =int64
  LispCharacter* = ref object of LispT
    codepoint*: LispCodepoint

  LispNumber* = ref object of LispT


  LispArray* = ref object of LispT
    elementType: LispT
  LispVector* = ref object of LispArray
  LispString* = ref object of LispVector


  LispFunction* = ref object of LispT
    args*: LispList
    doc*: string
    env*: LispEnvironment
    nativeProc*: proc ()


  LispPackage* = ref object of LispT
    name*: string
    nicknames*: seq[string]
    symbolTable*: TableRef[string, LispSymbol]


  SyntaxType* = enum
    stConstituent, stInvalid, stTermMacro, stNonTermMacro,
    stMultipleEscape, stSingleEscape, stWhitespace

  ConstituentTrait* = enum
    ctAlphabetic, ctDigit, ctPackageMarker, ctPlusSign, ctMinusSign,
    ctDot, ctDecimalPoint, ctRatioMarker, ctExponentMarker, ctInvalid
  ConstituentTraitList* = seq[ConstituentTrait]

  SyntaxTypeTable* = TableRef[LispCodepoint, SyntaxType]
  ConstTraitTable* = TableRef[LispCodepoint, ConstituentTraitList]
  DispatchMacroTable* = TableRef[seq[LispCodepoint], proc ()]

  ReadtableCase* = enum
    rcUpcase, rcDowncase, rcPreserve, rcInvert

  NewlineType* = enum
    nlLF, nlCR, nlCRLF

  LispReadtable* = ref object of LispT
    syntaxType*: SyntaxTypeTable
    constituentTrait*: ConstTraitTable
    singleMacro*: TableRef[LispCodepoint, proc ()]
    dispatchMacro*: DispatchMacroTable

    rcase*: ReadtableCase
    newlineType*: NewlineType


  LispEnvironment* = ref object of RootObj
    parent*: LispEnvironment
    binding*: TableRef[string, LispT]


  LispCondition* = ref object of Exception
