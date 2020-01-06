pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/openzeppelin-solidity/math/SafeMath.sol";


contract TestSafeMath {
	using SafeMath for uint256;
	
	function testMul() public {
		uint256 num = 2;
		Assert.equal(num.mul(3),6, '2*3 should be 6');
		num = 0;
		Assert.equal(num.mul(3),0, '0*3 should be 0');
	}

	function testDiv() public {
		uint256 num = 4;
		Assert.equal(num.div(2),2, '4/2 should be 2');
	}

	function testSub() public {
		uint256 num = 10;
		Assert.equal(num.sub(7),3, '10-7 should be 3');
	}

	function testAdd() public {
		uint256 num = 2;
		Assert.equal(num.add(3),5, '2+3 should be 5');
	}

	function testMod() public {
		uint256 num = 5;
		Assert.equal(num.mod(3),2, '5mod3 should be 2');
	}

}