version = "0.0.2"
author = "disruptek"
description = "wet"
license = "MIT"
requires "nim >= 0.20.0"
requires "terminaltables >= 0.1.1"
requires "cligen >= 0.9.38"
requires "dashing >= 0.1.1"
requires "forecast >= 1.0.0"

task test, "Runs the test suite":
  exec "nim c -d:ssl -r wet.nim"
