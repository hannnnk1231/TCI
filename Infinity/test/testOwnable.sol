pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/openzeppelin-solidity/ownership/Ownable.sol";


contract TestOwnable {
	Ownable ownable;

	function beforeEach() public {
		ownable = new Ownable();
	}

	function testTransferOwnership() public {
		address test = 0xc0ffee254729296a45a3885639AC7E10F9d54979;
		ownable.transferOwnership(test);
		Assert.equal(ownable.owner(),test, 'Owner should be transfer');
	}

	function testRenounceOwnership() public {
		ownable.renounceOwnership();
		Assert.equal(ownable.owner(),address(0), 'Owner should be renounced');
	}

}