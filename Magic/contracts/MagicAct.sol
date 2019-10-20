pragma solidity >=0.4.24 <0.6.0;

import "./Magic.sol";

contract MagicAct is Magic {

	event Act(uint _type);

	// type 0: Card trick, 1:Party show, 2: Stage magic, 3: Illution

	function act(uint _type) public checkEnoughDonation(_type*100) {
		require(audience[msg.sender].cooldown[_type] <= now);
		_triggerCooldownAndCharging(_type);
		_payMagician(_type);
		emit Act(_type);
	}
}
