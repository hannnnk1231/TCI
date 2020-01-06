pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/openzeppelin-solidity/ownership/Claimable.sol";


contract TestClaimable {
	Claimable claimable;

	function beforeEach() public {
		claimable = new Claimable();
	}

	function testTransferOwnership() public {
		address test = 0xc0ffee254729296a45a3885639AC7E10F9d54979;
		claimable.transferOwnership(test);
		Assert.equal(claimable.pendingOwner(),test, 'Owner should be transfered');
	}

	function testClaimOwnership() public {
		claimable.claimOwnership();
		Assert.equal(claimable.pendingOwner(),address(0), 'Owner should be claimed');
	}

}