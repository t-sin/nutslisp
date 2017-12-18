import tables

type
  LispT* = ref object of RootObj
  LispNil* = ref object of LispT

  LispCons* = ref object of LispT
    car*: LispT
    cdr*: LispT
  LispList* = ref object of LispCons

  LispSymbol* = ref object of LispT
    name*: string
    value*: LispT
    # function*: function
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
    #args*: LispLambdaList
    # returnType*: LispTypeSpec
    doc*: string
    # env*: LispEnv
    nativeProc*: proc


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
  DispatchMacroSeq* = array[int32, LispCodepoint]

  ReadtableCase* = enum
    rcUpcase, rcDowncase, rcPreserve, rcInvert

  NewlineType* = enum
    nlLF, nlCR, nlCRLF

  LispReadtable* = ref object of LispT
    syntaxType*: SyntaxTypeTable
    constituentTrait*: ConstTraitTable
    singleMacro*: TableRef[LispCodepoint, proc ()]
    dispatchMacro*: TableRef[DispatchMacroSeq, proc ()]

    rcase*: ReadtableCase
    newlineType*: NewlineType


  LispCondition* = ref object of Exception
