pragma solidity >=0.4.24 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/InfinityGame.sol";


contract TestInfinityGame {
	InfinityGame infinityGame;
	uint public initialBalance = 2 ether;
	
	function beforeEach() public {
		infinityGame = new InfinityGame();
	}
	
	function testBet() public {
		ThrowProxy throwproxy = new ThrowProxy(address(infinityGame));
      	InfinityGame(address(throwproxy)).bet.value(0.1 ether)(10);
      	(bool r, ) = throwproxy.execute.gas(200000)(); 
      	Assert.isTrue(r, "Should be true because is should throw!");
      	InfinityGame(address(throwproxy)).bet.value(0.2 ether)(10);
      	(r, ) = throwproxy.execute.gas(200000)(); 
      	Assert.isFalse(r, "Should be true because is should throw!");
	}

	function testCreateGame() public {
		infinityGame.createGame();
	}

	function testSettlementGame() public {
		infinityGame.settlementGame(0);
	}

	function testWhoIsWinner() public {
		Assert.equal(infinityGame._whoIsWinner(0),0,'gg');
	}
}

contract ThrowProxy {
 	address public target;
  	bytes data;


  	constructor(address _target) payable public{
  		target = _target;
  	}

 	 //prime the data using the fallback function.
  	function() external{
  	  	data = msg.data;
  	}

 	function execute() public returns (bool, bytes memory) {
 		return target.call(data);
 	}
}