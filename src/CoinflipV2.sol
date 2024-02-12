// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

error SeedTooShort();

contract CoinflipV2 is Ownable {
    string public seed;

    constructor() Ownable() {
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
        // Check if the NewSeed has a length of at least 10 characters
        if (bytes(NewSeed).length < 10) {
            revert SeedTooShort();
        }

        // Rotate the NewSeed 5 times
        string memory rotatedSeed = rotateString(NewSeed, 5);

        // Set the seed variable to the rotated seed
        seed = rotatedSeed;
    }

    // Helper function to generate 10 random flips based on the seed
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

    // Helper function to rotate a string by a specified number of positions
    function rotateString(string memory str, uint rotations) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint len = strBytes.length;

        // Calculate the effective number of rotations
        uint effectiveRotations = rotations % len;

        // Create a new bytes array to store the rotated string
        bytes memory rotated = new bytes(len);

        // Perform the rotation
        for (uint i = 0; i < len; i++) {
            uint rotatedIndex = (i + len - effectiveRotations) % len;
            rotated[rotatedIndex] = strBytes[i];
        }

        return string(rotated);
    }
}
