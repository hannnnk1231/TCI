pragma solidity >=0.4.24;


import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract Magic is ERC20, ERC20Detailed {

  uint256 public constant INITIAL_SUPPLY = 1e4 * (1e18);
  address public customer;
  uint public magician_pocket;
  constructor() public ERC20Detailed("MagicToken", "MAG", 18) {
    _mint(msg.sender, INITIAL_SUPPLY);
    customer=msg.sender;
  }
  function Donate(address reciever, uint amount) public {
      magician_pocket+=amount;
      transfer(reciever,amount);
  }
  function Act() public view returns (string memory) {
      if (magician_pocket<100) return("Magician is sleeping");
      else if(magician_pocket>=100 && magician_pocket <1000)
          return("Let's do a card trick!");
      else if(magician_pocket>=1000 && magician_pocket<5000)
          return("Magician is ready for a party show!");
      else if(magician_pocket>=5000 && magician_pocket<10000)
          return("Amazing dove trick!");
      else if(magician_pocket>=10000)
          return("A Car Appears out of nowhere!");
      
  }

}