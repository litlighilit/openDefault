# To run these tests, simply execute `nimble test`.

import unittest

import openDefault
test "open default browser":
  openDefaultBrowser()

test "open default":
  expect AssertionDefect:
    openDefault ""

