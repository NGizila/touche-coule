// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import 'hardhat/console.sol';

abstract contract Ship {
  function update(uint x, uint y) public virtual;
  function fire() public virtual returns (uint, uint);
  function place(uint width, uint height) public virtual returns (uint, uint);
}

contract TestShip is Ship{
  uint private num1;
  uint private num2;
  function update(uint x, uint y) public override virtual {num1 = x; num2=y;}
  function fire() public override virtual returns (uint, uint) {return (5,5);}
  function place(uint width, uint height) public override virtual returns (uint, uint) { return (1,1); }
}
