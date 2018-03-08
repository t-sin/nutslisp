import tables


when not defined(javascript):
  type
    LispObjectId* = uint32
    LispT* = ref object of RootObj
      id*: LispObjectId

when defined(javascript):
  type
    LispObjectId* = int32
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

  LispNull* = ref object of LispList

  LispSpecialCharacter* = enum
    lcharNewline = -2
    lcharPage = -1
  LispCodepoint* =int64
  LispCharacter* = ref object of LispT
    codepoint*: LispCodepoint

  LispNumber* = ref object of LispT
  LispInteger* = ref object of LispNumber
    value*: int


  LispArrayBase*[T] = ref object of LispT
    content*: seq[T]
  LispArray* = LispArrayBase[LispArray]
  LispVector*[T] = LispArrayBase[T]
  LispString* = LispVector[LispCharacter]


  LArg* = ref object of LispT
    name*: LispSymbol
    defaultValue*: LispT
  LOrdinalArgs* = seq[LArg]
  # LOptionalArgs* = TableRef[LispObjectId, LArg]
  # LKeywordArgs* = TableRef[LispObjectId, LArg]

  LispLambdaList* = ref object of LispT
    ordinal*: LOrdinalArgs
    # optional*: LOptionalArgs
    # keyword*: LKeywordArgs

  LispFunction* = ref object of LispT
    lambdaList*: LispLambdaList
    nativeP*: bool
    body*: LispT
    nativeBody*: proc (rt: LispRuntime, args: LispList): LispT


  LispSymbolId* = LispObjectId
  LispBinding*[T] = ref object
    binding*: TableRef[LispSymbolId, T]

  LispPackage* = ref object of LispT
    name*: string
    nicknames*: seq[string]
    environment*: TableRef[string, LispSymbol]

  LispEnvironment* = ref object of LispT
    parent*: LispEnvironment

  LispGrobalEnvironment* = ref object of LispEnvironment
    packageTable*: TableRef[string, LispPackage]
    currentPackage*: LispPackage

    # types*: LispBinding[LispType]

    keywordPkg*: LispPackage
    symbolT*: LispT
    symbolNil*: LispT

  LispDynamicEnvironment* = ref object of LispEnvironment
    dynamicVars*: LispBinding[LispT]
    # catches*: LispBinding[LispCatches]
    # unwindEnd*: LispBinding[LispUnwindEnd]
    # handlers*: LispBinding[LispHandler]

  LispLexicalEnvironment* = ref object of LispEnvironment
    variables*: LispBinding[LispT]
    functions*: LispBinding[LispFunction]

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

  # runtime will remove in near future
  LispRuntime* = ref object of RootObj
    readtable*: LispReadtable
    packageTable* : TableRef[string, LispPackage]
    currentPackage*: LispPackage

    keywordPkg*: LispPackage
    symbolT*: LispT
    symbolNil*: LispNull
