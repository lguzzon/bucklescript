// Generated CODE, PLEASE EDIT WITH CARE
'use strict';


var v = [0];

while(console.log("" + v[0]), ++ v[0], +(v[0] < 10)) {
  
};

function fib(n) {
  if (n === 0 || n === 1) {
    return 1;
  }
  else {
    return fib(n - 1) + fib(n - 2);
  }
}

var x = [3];

while(function () {
      var y = 3;
      console.log("" + x[0]);
      ++ y;
      ++ x[0];
      return +(fib(x[0]) + fib(x[0]) < 20);
    }()) {
  console.log("" + 3);
};

exports.v   = v;
exports.fib = fib;
exports.x   = x;
/*  Not a pure module */
