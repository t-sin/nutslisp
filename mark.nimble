# Package

version       = "0.1.0"
author        = "TANAKA Shinichi"
description   = "Little squirrel program"
license       = "GPLv3"

bin = @["mark"]
srcDir = "src"
# Dependencies

requires "nim >= 0.17.2"

task test, "Run the mark and SCL tests":
  withDir "tests":
    exec "nim c -r tester"
