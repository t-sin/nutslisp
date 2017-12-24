import tables


type
  LispObjectId* = uint32
  LispT* = ref object of RootObj
    id*: LispObjectId

var lispObjectCount*: LispObjectId = 0

proc makeLispObject*[L](): L =
  var lispObj = L()
  lispObj.id = lispObjectCount
  lispObjectCount += 1
  return lispObj


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
    environment*: LispEnvironment

  LispEnvironment* = ref object of LispT
    parent*: LispEnvironment
    binding*: TableRef[LispObjectId, LispT]


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


  LispCondition* = ref object of Exception
