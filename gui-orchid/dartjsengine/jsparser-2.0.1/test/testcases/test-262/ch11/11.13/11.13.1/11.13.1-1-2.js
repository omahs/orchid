// Copyright (c) 2012 Ecma International.  All rights reserved.
// Ecma International makes this code available under the terms and conditions set
// forth on http://hg.ecmascript.org/tests/test262/raw-file/tip/LICENSE (the
// "Use Terms").   Any redistribution of this code must retain the above
// copyright and this notice and otherwise comply with the Use Terms.

/*---
info: PutValue operates only on references (see step 1).
es5id: 11.13.1-1-2
description: >
    simple assignment throws ReferenceError if LeftHandSide is not a
    reference (string)
includes: [runTestCase.js]
---*/

function testcase() {
  try {
    eval("'x' = 42");
  }
  catch (e) {
    if (e instanceof ReferenceError) {
      return true;
    }
  }
 }
runTestCase(testcase);
