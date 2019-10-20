pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Magic.sol";

contract ExposedMagic is Magic {
	function _testTrigger(uint _type) public {
		_triggerCooldown(_type);
	}

	function _testPaymagician(uint _type) public {
		_payMagician(_type);
	}
}

contract TestMagic {

	uint expectedType = 2;

	function testMagician() public {
		Magic magic = new Magic();
		address expectedMagician = address(this);
		address returnedMagician = magic.getMagician();
		Assert.equal(returnedMagician, expectedMagician, "The magician's should be the owner.");
	}

	function testDonate() public payable{
		Magic magic = new Magic();
		magic.donate();
		uint expectedDonation = magic.getDonation(address(this));
		Assert.equal(msg.value, expectedDonation, "The donation should equal to msg.value.");
	}

	function testTrigger() public {
		ExposedMagic e = new ExposedMagic();
		e._testTrigger(expectedType);
		uint returnedCooldownTime = e.getCooldownTime(expectedType);
		uint expectedCooldownTime = now + 1 days;
		Assert.equal(returnedCooldownTime, expectedCooldownTime, "The cooldown time should be added 1 day.");
	}

	/*

	function testPayMagician() public {
		ExposedMagic e = new ExposedMagic();
		e._testPaymagician(expectedType);
		uint expectedCharge = 200;
		uint returnedMagicianBalance = e.getMagician().balance;
		Assert.equal(returnedMagicianBalance, expectedCharge, "The magician should earn 200.");
	}
	*/

}