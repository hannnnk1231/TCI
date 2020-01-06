pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Randomness.sol";


contract TestRandomness {
	Randomness randomness;
	bytes32 seed = "hحَi";

	function beforeEach() public {
		randomness = new Randomness();
	}

	function testRand() public {
		bytes32 key = 'test';
		seed ^= key;
		bytes32 test_rand = keccak256(abi.encodePacked(key, seed, block.timestamp, block.difficulty, "台灣きन्दी한حَNo.1 :) "));
		Assert.equal(randomness.rand(key),test_rand, 'Return');
	}

}