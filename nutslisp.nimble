# Package

version       = "0.1.0"
author        = "TANAKA Shinichi"
description   = "Trivial Lisp-2 Interpreter"
license       = "GPLv3"

bin = @["nutslisp"]
srcDir = "src"
# Dependencies

requires "nim >= 0.17.2"

task buildjs, "Build nutslisp for github pages":
  withDir "src":
    exec "nim js -d:javascript -o:../docs/nutslisp.js nutslisp.nim"

task test, "Run Nuts Lisp tests":
  withDir "tests":
    exec "nim c -r tester"

task run, "Run Nuts Lisp":
  withDir "src":
    exec "nim c -r nutslisp"
