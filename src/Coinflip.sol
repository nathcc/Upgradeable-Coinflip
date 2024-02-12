// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SeedTooShort();

contract Coinflip is OwnableUpgradeable, UUPSUpgradeable {
    string public seed;

    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        // Set the seed to "It is a good practice to rotate seeds often in gambling".
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    function userInput(uint8[10] calldata Guesses) external view returns(bool){
        uint8[10] memory generatedGuesses = getFlips();

        for (uint i = 0; i < 10; i++) {
            if (Guesses[i] != generatedGuesses[i]) {
                return false;
            }
        }
        return true;
    }

    function seedRotation(string memory NewSeed) public onlyOwner {
        bytes memory NewSeedBytes = bytes(NewSeed);
        uint seedLength = NewSeedBytes.length;

        if (seedLength < 10){
            revert SeedTooShort();
        }
        
        seed = NewSeed;
    }

    function getFlips() public view returns(uint8[10] memory){
        bytes memory stringInBytes = bytes(seed);
        uint seedLength = stringInBytes.length;

        uint8[10] memory flips;
        uint interval = seedLength / 10;

        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(keccak256(abi.encodePacked(stringInBytes[i*interval], block.timestamp)));
            
            if (randomNum % 2 == 0) {
                flips[i] = 1;
            } else {
                flips[i] = 0;
            }
        }
        return flips;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
