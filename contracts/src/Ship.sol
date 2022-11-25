// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import 'hardhat/console.sol';

abstract contract Ship {
  function update(uint x, uint y) public virtual;
  function fire() public virtual returns (uint, uint);
  function place(uint width, uint height) public virtual returns (uint, uint);
}

contract TestShip is Ship{
  uint xs;
  uint ys;

  function update(uint x, uint y) public override virtual {xs = x; ys=y;}
  function fire() public override virtual returns (uint, uint) {
    // Auto destruction - friendly fire
    return(xs,ys);
  }
  
  function place(uint width, uint height) public override virtual returns (uint, uint) { 

    return (xs,ys); 
    
    }
}
