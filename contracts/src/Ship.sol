// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import '../node_modules/hardhat/console.sol';

abstract contract Ship {
  address owner;
  uint index;

  struct Position{
    uint current_x;
    uint current_y;
    bool eliminated;
  }

  struct PositionTouche{
      uint _x;
      uint _y;
      bool first_fire;
  }

  mapping(uint => Position[]) public position_ship; 
  mapping(uint => PositionTouche) public position_touche;

  function update(uint x, uint y, uint _index) public virtual;
  function fire(uint width, uint height, uint _index, address _owner) public virtual returns (uint, uint);
  function place(uint width, uint height) public virtual returns (uint, uint);
  function position_current(uint _index) public virtual returns (uint, uint);
}


contract FirstShip is Ship{

  function position_current(uint _index) override(Ship) public returns (uint, uint) {
      uint x = position_ship[_index][0].current_x;
      uint y = position_ship[_index][0].current_y;
      return (x,y);
  }

  function update(uint x, uint y, uint _index) override(Ship) public {
    Position memory currentPosition;
    currentPosition.current_x = x;
    currentPosition.current_y = y;
    position_ship[_index].push(currentPosition);
    console.log("Pushed");
  }

  function fire(uint width, uint height, uint _index, address _owner) override(Ship) public returns (uint, uint) {
    uint x;
    uint y;
    
    for(uint i = 0; i < position_ship[_index].length; i++){
      uint random = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, _owner))) % 50;
      if(position_touche[_index].first_fire){
        x = (position_touche[_index]._x + random + (i + 1)) % width;
        y = (position_touche[_index]._y + random + i) % height;
        position_touche[_index]._x = x;
        position_touche[_index]._y = y;
       
      }else{
        x = (position_ship[_index][i].current_x + random  + (i + 1)) % width;
        y = (position_ship[_index][i].current_y + random + i) % height;
        position_touche[_index]._x = x;
        position_touche[_index]._y = y;
        position_touche[_index].first_fire = false;
      }
    }
    return (x, y);
  }

  function place(uint width, uint height) override(Ship) public returns (uint, uint) { 
    uint randNonce = 0;
    randNonce+=1;
    uint x;
    uint y;
    x=uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 50;
    randNonce+=1;
    y=uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 50;
     return (x, y);
  }
} 


contract SecondShip is Ship{
  /**
   */

  function position_current(uint _index) override(Ship) public returns (uint, uint) {
      uint x = position_ship[_index][0].current_x;
      uint y = position_ship[_index][0].current_y;
      return (x,y);
  }

  function update(uint x, uint y, uint _index) override(Ship) public {
    Position memory currentPosition;
    currentPosition.current_x = x;
    currentPosition.current_y = y;
    position_ship[_index].push(currentPosition);
  }

  function fire(uint width, uint height, uint _index, address _owner) override(Ship) public returns (uint, uint) {
    uint x;
    uint y;
  
    for(uint i = 0; i < position_ship[_index].length; i++){

      uint random = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty, _owner))) % 50;

      if(position_touche[_index].first_fire){
        x = (position_touche[_index]._x + random + (i + 1)) % width;
        y = (position_touche[_index]._y + random + i) % height;
        position_touche[_index]._x = x;
        position_touche[_index]._y = y;
      
      }else{
        x = (position_ship[_index][i].current_x + random  + (i + 1)) % width;
        y = (position_ship[_index][i].current_y + random + i) % height;
        position_touche[_index]._x = x;
        position_touche[_index]._y = y;
        position_touche[_index].first_fire = false;
      }
    }
    return (x, y);
  }

  function place(uint width, uint height) override(Ship) public returns (uint, uint) { 

    // Initializing the state variable
    uint randNonce = 0;
    randNonce+=1;
    uint x;
    uint y;
    
    x=uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 50;
    randNonce+=1;
    
    y=uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % 50;
     return (x, y);
  }
} 