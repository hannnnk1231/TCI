pragma solidity >=0.4.24 <0.6.0;

contract Magic {

	address payable magician;
	uint cooldownTime = 1 days;

	struct Audiences {
		uint donation;
		uint32 [4] cooldown;
	}

	mapping (address=>Audiences) public audience;

	constructor() public {
		magician = msg.sender;
	}

	modifier checkEnoughDonation(uint _price) {
		require(audience[msg.sender].donation >= _price);
		_;
	}

	function donate() public payable {
      	audience[msg.sender].donation+=msg.value;
  	}

  	function getDonation(address _audience) public view returns(uint){
  		return audience[_audience].donation;
  	}

  	function _triggerCooldownAndCharging(uint _type) internal {
  		audience[msg.sender].cooldown[_type] += uint32(now + cooldownTime);
  	}

  	function _payMagician(uint _type) internal {
  		uint charge=_type*100;
  		magician.transfer(charge);
  		audience[msg.sender].donation-=charge;
  	}
}