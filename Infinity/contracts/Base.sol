pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./openzeppelin-solidity/math/SafeMath.sol";
import "./openzeppelin-solidity/ownership/Claimable.sol";
import "./Randomness.sol";


contract Base is Claimable{
    using SafeMath for uint256;
    using SafeMath for uint8;

    uint256 constant public NUMBER_OF_HANDCARD = 5;
    uint256 constant public NUMBER_OF_PIP = 7;
    uint256 constant public NUMBER_OF_SUIT = 4;
    uint256 constant public NUMBER_OF_TOTAL_CARDS = 28;
    uint256 constant public NUMBER_OF_PLAYER = 5;

    uint8[NUMBER_OF_TOTAL_CARDS] public cardArray = [
         0,  1,  2,  3,  4,  5,  6,
         7,  8,  9, 10, 11, 12, 13,
        14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27
    ];

    Randomness public randomnessContract = new Randomness();
    uint256 public playerLimit = 0.1 ether;
    uint256 public minimumPoolBalance = 0.5 ether;
    uint256 public adminEtherBalance = 0;
    uint256 public houseFee = 10; // 10%
    uint256 public timeOfAGame = 3 minutes;

    enum Suit { Diamond, Club, Heart, Spade }
    enum Value { Eight, Nine, Ten, Jack, Queen, King, Ace }
    enum HandEnum { Zilch, OnePair, TwoPair, ThreeOfAKind, Straight, Flush, FullHouse, FourOfAKind, StraightFlush }

    struct Card {
        Suit suit;
        Value value;
    }

    struct Player {
        uint256 playerID;
        mapping(uint256 => Card) handCard;
        uint256 handCardLength;
        mapping(uint256 => address) bettor;
        uint256 bettorLength;
    }

    struct Game {
        uint256 gameID;
        mapping(uint256 => uint256) playersID;
        uint256 playersLength;
        mapping(uint256 => uint256) deck;
        uint256 deckLength;
        uint256 dealedNumber;
        uint256 endTime;
    }

    struct EvaluateHand {
        HandEnum handValue;
        int8[NUMBER_OF_HANDCARD] compareCardArr;
        int8 compareSuit;
    }

    mapping(uint256 => Game) public IDToGames;
    mapping(uint256 => Player) public IDToPlayers;

    function getPlayerInfoOfAGame(uint256 _gameID, uint256 _playerNum) internal view returns(Player storage) {
        return IDToPlayers[IDToGames[_gameID].playersID[_playerNum]];
    }

    function getGameFundPool(uint256 _gameID) public view returns(uint256) {
        uint256 pool = 0;
        for (uint256 i = 0; i < NUMBER_OF_PLAYER; i++) {
            pool = pool.add(getPlayerInfoOfAGame(_gameID, i).bettorLength);
        }
        pool = pool.mul(playerLimit);
        return pool;
    }

    function setPlayerLimit(uint256 _newLimit) public onlyOwner {
        playerLimit = _newLimit;
    }

    function setHouseFee(uint256 _newHouseFee) public onlyOwner {
        houseFee = _newHouseFee;
    }

    function setTimeOfAGame(uint256 _newGameTime) public onlyOwner {
        timeOfAGame = _newGameTime;
    }

    function _rand(uint256 _num) internal onlyOwner returns(uint256) {
        return uint256(randomnessContract.rand(
                keccak256(
                    abi.encodePacked(
                        msg.data,
                        msg.sender,
                        _num
                    )
                )
            ));
    }
}