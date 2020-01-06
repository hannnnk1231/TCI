pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/openzeppelin-solidity/lifecycle/Pausable.sol";


contract TestPausable {
	Pausable pausable;

	function beforeEach() public {
		pausable = new Pausable();
	}

	function testPause() public {
		pausable.pause();
		Assert.isTrue(pausable.paused(),'It should pause');
	}

	function testUnPause() public {
		pausable.unpause();
		Assert.isFalse(pausable.paused(),'It should unpause');
	}

}