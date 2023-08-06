// Copyright 2009 the Sputnik authors.  All rights reserved.
// This code is governed by the BSD license found in the LICENSE file.

/*---
info: Operator x % y returns ToNumber(x) % ToNumber(y)
es5id: 11.5.3_A3_T2.4
description: >
    Type(x) is different from Type(y) and both types vary between
    Number (primitive or object) and Undefined
---*/

//CHECK#1
if (isNaN(1 % undefined) !== true) {
  $ERROR('#1: 1 % undefined === Not-a-Number. Actual: ' + (1 % undefined));
}

//CHECK#2
if (isNaN(undefined % 1) !== true) {
  $ERROR('#2: undefined % 1 === Not-a-Number. Actual: ' + (undefined % 1));
}

//CHECK#3
if (isNaN(new Number(1) % undefined) !== true) {
  $ERROR('#3: new Number(1) % undefined === Not-a-Number. Actual: ' + (new Number(1) % undefined));
}

//CHECK#4
if (isNaN(undefined % new Number(1)) !== true) {
  $ERROR('#4: undefined % new Number(1) === Not-a-Number. Actual: ' + (undefined % new Number(1)));
}
