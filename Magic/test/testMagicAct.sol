pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MagicAct.sol";

contract TestMagicAct {	

	uint public initialBalance = 1 ether;

	function testAct() public {
		MagicAct magicAct = MagicAct(DeployedAddresses.MagicAct());
		uint initMagicianBalance = magicAct.getMagician().balance;
		magicAct.donate.value(300 finney)();
		Assert.equal(300 finney, magicAct.getDonation(address(this)), "The audience should donate 300 finney.");
		magicAct.act(1);
		Assert.equal(magicAct.getCooldownTime(1), now + 1 days, "The cooldown time should be added 1 day.");
		Assert.equal(magicAct.getMagician().balance, initMagicianBalance + 100 finney, "The magician should earn 100 finney.");
		Assert.equal(magicAct.getDonation(address(this)), 200 finney, "The audience should remain 200 finney.");
	}

	function testPayMagician() public {
		uint expectedType = 2;
		MagicAct magicAct = MagicAct(DeployedAddresses.MagicAct());
		uint initMagicianBalance = magicAct.getMagician().balance;
		magicAct.donate.value(300 finney)();
		Assert.equal(magicAct.getDonation(address(this)), 500 finney, "The audience should donate 500 finney(300+200remaining).");
		magicAct.payMagician(expectedType);
		Assert.equal(magicAct.getMagician().balance, initMagicianBalance + 200 finney, "The magician should earn 200 finney.");
		Assert.equal(magicAct.getDonation(address(this)), 300 finney, "The audience should remain 300 finney.");
	}

}