pragma solidity >=0.4.24 <0.6.0;

import "./openzeppelin-solidity/ownership/Claimable.sol";

contract Randomness is Claimable {

    bytes32 private seed = "hحَi";

    function rand(bytes32 key) public onlyOwner returns (bytes32) {
        seed ^= key;
        return keccak256(abi.encodePacked(key, seed, block.timestamp, block.difficulty, "台灣きन्दी한حَNo.1 :) "));
    }
}
