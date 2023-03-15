// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

type Ux160 is uint8;

using {add as +, add} for Ux160 global; // for all contracts in file
using {sub as -, sub} for Ux160 global; // for all contracts in file
using {div as /, div} for Ux160 global; // for all contracts in file
using {eq as ==} for Ux160 global; // for all contracts in file

function add(Ux160 a, Ux160 b) pure returns (Ux160) {
    return  Ux160.wrap(Ux160.unwrap(a) + Ux160.unwrap(b));
}

function sub(Ux160 a, Ux160 b) pure returns (Ux160) {
        return  Ux160.wrap(Ux160.unwrap(a) - Ux160.unwrap(b));

}

function div(Ux160 a, Ux160 b) pure returns (Ux160) {
    return  Ux160.wrap(Ux160.unwrap(a) / Ux160.unwrap(b));
}

function eq(Ux160 a, Ux160 b) pure returns (bool) {
    return  a == b;
}



function asmAdd(Ux160 a, Ux160 b) pure returns (Ux160 c) {
    assembly {
        c := add(a, b)
    }
}

function asmDiv(Ux160 a, Ux160 b) pure returns (Ux160 c) {
    assembly {
        c := div(a, b)
    }
}

contract UDOContract {

    function test1(Ux160 a, Ux160 b) public pure returns(bool) {

    Ux160 z = a + b;
    Ux160 q = a.add(b);
    Ux160 w = add(a, b);
    Ux160 x = a - b;
    Ux160 y = a.sub(b);
        return z == w;
    }

    function asmOp(Ux160 a, Ux160 b, Ux160 c) public pure returns (Ux160) {
        return a / (b + c);
    }

    function op(uint8 a, uint8 b, uint8 c) public pure returns (uint8) {
        return a / (b + c);
    }

}

