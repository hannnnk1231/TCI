pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Magic.sol";

contract ExposedMagic is Magic {
	function _testTrigger(uint _type) public {
		_triggerCooldown(_type);
	}
}

contract TestMagic {

	uint expectedType = 2;
	uint public initialBalance = 1 ether;

	function testMagician() public {
		Magic magic = new Magic();
		Assert.equal(magic.getMagician(), address(this), "The magician's should be the owner.");
	}

	function testDonate() public payable{
		Magic magic = new Magic();
		magic.donate.value(200 finney)();
		uint returnedDonation = magic.getDonation(address(this));
		Assert.equal(returnedDonation, 200 finney, "The donation should equal to msg.value.");
	}

	function testTrigger() public {
		ExposedMagic e = new ExposedMagic();
		e._testTrigger(expectedType);
		uint returnedCooldownTime = e.getCooldownTime(expectedType);
		uint expectedCooldownTime = now + 1 days;
		Assert.equal(returnedCooldownTime, expectedCooldownTime, "The cooldown time should be added 1 day.");
	}
}