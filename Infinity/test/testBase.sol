pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Base.sol";


contract TestBase {
	Base base;
	
	function beforeEach() public {
		base = new Base();
	}

	function testSetPlayerLimit() public {
		uint256 test = 1 ether;
		base.setPlayerLimit(test);
		Assert.equal(base.playerLimit(), test, "The playerLimit should be 1 ether.");
	}

	function testSetHouseFee() public {
		uint256 test = 20;
		base.setHouseFee(test);
		Assert.equal(base.houseFee(), test, "The houseFee should be 20.");
	}

	function testSetTimeOfAGame() public {
		uint256 test = 2 minutes;
		base.setTimeOfAGame(test);
		Assert.equal(base.timeOfAGame(), test, "The TimeOfAGame should be 2 minutes.");
	}
	
	function test_rand() public {
		Assert.equal(base.getGameFundPool(2), 0, "The TimeOfAGame should be 2 minutes.");
	}
	

}