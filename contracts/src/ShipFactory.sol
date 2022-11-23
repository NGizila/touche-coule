// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./Main.sol";
import "hardhat/console.sol";

// contract ShipFactory {
//     event NewShip(uint x, uint y, uint _dna);

//     uint dnaDigits = 16;
//     uint dnaModulus = 10 ** dnaDigits;

//     struct ShipStruct {
//         uint x;
//         uint y;
//         uint _dna;
//     }

//     ShipStruct[] public ships;

//     function _createShip(uint x, uint y, uint _dna) private {
//         ships.push(ShipStruct(x,y,_dna));
//         uint id = ships.length -1;
//         emit NewShip(x,y,_dna);
//     }

//     function _generateRandomDna(string memory name) private view returns (uint) {
//         uint rand = uint(keccak256(abi.encodePacked(name)));
//         return rand % dnaModulus;
//     }

//        function createRandomShip(string _name) public {
//         uint randDna = _generateRandomDna(_name);
//          for (uint i = 0; i < ShipStruct; i++) {
//             Ship ship = ShipStruct[i];
//             _createShip(ship.x, ship.y, randDna);
//             }   
    
//     }


    
// }