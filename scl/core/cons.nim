import objects
import runtime


proc atom*(obj: LispT): bool =
  if obj of LispCons:
    return false
  else:
    return true

proc lisp_atom*(rt: LispRuntime, obj: LispT): LispT =
  nil

proc lisp_car*(rt: LispRuntime, c: LispCons): LispT =
  return c.car

proc lisp_cdr*(rt: LispRuntime, c: LispCons): LispT =
  return c.cdr

proc lisp_cons*(rt: LispRuntime, obj1: LispT, obj2: LispT): LispT =
  return LispCons(car: obj1, cdr: obj2)
