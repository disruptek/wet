version = "0.0.5"
author = "disruptek"
description = "wet"
license = "MIT"
requires "nim >= 0.20.0"
requires "https://github.com/disruptek/nim-terminaltables.git#nim111"
requires "cligen >= 0.9.40"
requires "dashing >= 0.1.1"
requires "https://github.com/disruptek/forecast.git >= 1.0.2"

task test, "Runs the test suite":
  exec "nim c -d:ssl -r wet.nim"
