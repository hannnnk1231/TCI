pragma solidity ^0.4.24;

import "./Base.sol";
import "./openzeppelin-solidity/lifecycle/Pausable.sol";

contract InfinityGame is Base, Pausable{
    function bet(uint256 _playerID) public payable whenNotPaused {
        require (msg.value == playerLimit);
        Player storage player = IDToPlayers[_playerID];
        player.bettor[player.bettorLength] = msg.sender;
        player.bettorLength = player.bettorLength.add(1);
    }

    event CreatePlayer (uint256 playerID);
    event CreatGame (uint256 gameID);

    function createGame() public onlyOwner whenNotPaused {
        uint256 gameID = _rand(0);
        uint256 playerID = _rand(gameID);

        IDToGames[gameID] = Game({
            gameID: gameID,
            playersLength: NUMBER_OF_PLAYER,
            deckLength: NUMBER_OF_TOTAL_CARDS,
            dealedNumber: 0,
            endTime: block.timestamp.add(timeOfAGame)
        });

        _shuffle(gameID);

        for (uint256 i = 0; i < NUMBER_OF_PLAYER; i++) {
            playerID = _rand(playerID);

            IDToPlayers[playerID] = Player({
                playerID: playerID,
                handCardLength: 0,
                bettorLength: 0
            });

            IDToGames[gameID].playersID[i] = playerID;
            _dealCards(gameID, i, 3);

            emit CreatePlayer(playerID);
        }

        emit CreatGame(gameID);
    }

    function _dealCards(uint256 _gameID, uint256 _playerNum, uint256 _numOfDeal) private onlyOwner {
        Player storage player = getPlayerInfoOfAGame(_gameID, _playerNum);
        Game storage game = IDToGames[_gameID];
        mapping(uint256 => uint256) deck = game.deck;
        uint256 numOfDeal = _numOfDeal.add(player.handCardLength);

        for (uint i = player.handCardLength; i < numOfDeal; i++) {
            player.handCard[i] = Card(Suit(deck[game.dealedNumber].mod(4)), Value(deck[game.dealedNumber].div(4)));
            game.dealedNumber = game.dealedNumber.add(1);
            player.handCardLength = player.handCardLength.add(1);
        }
    }

    function _shuffle(uint256 _gameID) private onlyOwner {
        mapping(uint256 => uint256) deck = IDToGames[_gameID].deck;
        uint8[NUMBER_OF_TOTAL_CARDS] memory tmpdeck = cardArray;
        uint256 num = NUMBER_OF_TOTAL_CARDS;
        uint8 tmp;
        uint256 n;

        for (uint256 i = 0; i < NUMBER_OF_TOTAL_CARDS-1; i++) {
            n = i.add(_rand(i).mod(num));
            num = num.sub(1);
            tmp = tmpdeck[n];
            tmpdeck[n] = tmpdeck[i];
            tmpdeck[i] = tmp;
        }

        for (i = 0; i < NUMBER_OF_TOTAL_CARDS; i++) {
            deck[i] = tmpdeck[i];
        }
    }

    function settlementGame(uint256 _gameID) public onlyOwner whenNotPaused {
    //function settlementGame(uint256 _gameID, uint256 _winnerPlayer) public onlyOwner {
        require(block.timestamp >= IDToGames[_gameID].endTime);
        uint256 pool = getGameFundPool(_gameID);

        for (uint256 i = 0; i < NUMBER_OF_PLAYER; i++) {
            _dealCards(_gameID, i, 2);
            _sortHandCard(getPlayerInfoOfAGame(_gameID, i));
        }

        if (pool >= minimumPoolBalance) {
            uint256 winnerPlayer = _whoIsWinner(_gameID);
            if (IDToPlayers[winnerPlayer].bettorLength == 0) {
                adminEtherBalance = adminEtherBalance.add(pool);
            }
            else {
                adminEtherBalance = adminEtherBalance.add(pool.mul(houseFee).div(100));
                pool = pool.mul(100-houseFee).div(100);
                uint256 avgEther = pool.div(IDToPlayers[winnerPlayer].bettorLength);

                _distributionEther(winnerPlayer, avgEther);
            }
        }
        else {
            for (i = 0; i < NUMBER_OF_PLAYER; i++) {
                for (uint256 j = 0; j < getPlayerInfoOfAGame(_gameID, i).bettorLength; j++) {
                    getPlayerInfoOfAGame(_gameID, i).bettor[j].transfer(playerLimit);
                }
            }
        }
    }

    function _sortHandCard(Player storage _player) private {
        mapping(uint256 => Card) handCard = _player.handCard;
        uint8[NUMBER_OF_HANDCARD] memory tmp;
        uint8 tmpNumber;
        Card memory tmpCard;

        for (uint256 i = 0; i < 5; i++) {
            tmp[i] = uint8(handCard[i].value) * 4 + uint8(handCard[i].suit);
        }

        for (i = 0; i < NUMBER_OF_HANDCARD.sub(1); i++) {
            for (uint8 j = 0; j < NUMBER_OF_HANDCARD.sub(1).sub(i); j++) {
                if (tmp[j] > tmp[j+1]) {
                    tmpNumber = tmp[j+1];
                    tmp[j+1] = tmp[j];
                    tmp[j] = tmpNumber;

                    tmpCard = handCard[j+1];
                    handCard[j+1] = handCard[j];
                    handCard[j] = tmpCard;
                }
            }
        }
    }

    function _whoIsWinner(uint256 _gameID) public view returns (uint256) {
        uint8 winner = 0;
        EvaluateHand memory max = _evaluateHand(getPlayerInfoOfAGame(_gameID, 0));
        EvaluateHand memory tmp;

        for (uint8 i = 1; i < NUMBER_OF_PLAYER; i++) {
            tmp = _evaluateHand(getPlayerInfoOfAGame(_gameID, i));

            if (tmp.handValue > max.handValue) {
                max = tmp;
                winner = i;
            }
            else if (tmp.handValue == max.handValue) {
                for (uint8 j = 0; j < NUMBER_OF_HANDCARD; j++) {
                    if (tmp.compareCardArr[j] > max.compareCardArr[j]) {
                        max = tmp;
                        winner = i;
                        break;
                    }
                    else if (tmp.compareCardArr[j] < max.compareCardArr[j]) {
                        break;
                    }
                    else if (j == NUMBER_OF_HANDCARD.sub(1) && tmp.compareSuit > max.compareSuit) {
                        max = tmp;
                        winner = i;
                    }
                }
            }
        }

        return IDToGames[_gameID].playersID[winner];
    }

    function _evaluateHand(Player storage _player) private view returns(EvaluateHand) {
        uint8[NUMBER_OF_SUIT] memory suit_match = [0, 0, 0, 0];
        uint8[NUMBER_OF_PIP] memory pip_match = [0, 0, 0, 0, 0, 0, 0];
        int8[NUMBER_OF_HANDCARD] memory retOrder = [-1, -1, -1, -1, -1];
        int8[2] memory pairs = [-1, -1];
        int8 compareSuit = -1;
        HandEnum handValue = HandEnum.Zilch;
        mapping(uint256 => Card) _handCard = _player.handCard;

        for (uint256 i = 0; i < NUMBER_OF_HANDCARD; i++) {
            suit_match[uint8(_handCard[i].suit)] = uint8(suit_match[uint8(_handCard[i].suit)].add(1));
            pip_match[uint8(_handCard[i].value)] = uint8(pip_match[uint8(_handCard[i].value)].add(1));

            if (pip_match[uint8(_handCard[i].value)] == 4) {
                handValue = HandEnum.FourOfAKind;
                return EvaluateHand(handValue, retOrder, compareSuit);
            }
            else if (pip_match[uint8(_handCard[i].value)] == 3) {
                handValue = HandEnum.ThreeOfAKind;
                retOrder[0] = int8(_handCard[i].value);
            }
            else if (pip_match[uint8(_handCard[i].value)] == 2) {
                if (pairs[0] == -1) {
                    pairs[0] = int8(_handCard[i].value);
                }
                else {
                    pairs[1] = int8(_handCard[i].value);
                }
            }
        }

        if (suit_match[uint8(_handCard[0].suit)] == 5) {
            if (uint8(_handCard[4].value).sub(uint8(_handCard[0].value)) == 4) {
                handValue = HandEnum.StraightFlush;
                retOrder[0] = int8(_handCard[4].value);
            }
            else {
                handValue = HandEnum.Flush;
                for (i = 0; i < NUMBER_OF_HANDCARD; i++) {
                    retOrder[i] = int8(_handCard[4-i].value);
                }
            }
            compareSuit = int8(_handCard[4].suit);
        }
        else if (handValue == HandEnum.ThreeOfAKind) {
            if (pairs[1] != -1) {
                handValue = HandEnum.FullHouse;
            }
        }
        else{
            if (pairs[0] == -1) {
                if (uint8(_handCard[4].value).sub(uint8(_handCard[0].value)) == 4) {
                    handValue = HandEnum.Straight;
                    retOrder[0] = int8(_handCard[4].value);
                }
                else {
                    for (i = 0; i < NUMBER_OF_HANDCARD; i++) {
                        retOrder[i] = int8(_handCard[4-i].value);
                    }
                }
                compareSuit = int8(_handCard[4].suit);
            }
            // pair or two pair
            else {
                if (pairs[1] != -1) {
                    handValue = HandEnum.TwoPair;
                    if (pairs[0] > pairs[1]) {
                        retOrder[0] = pairs[0];
                        retOrder[1] = pairs[1];
                    }
                    else {
                        retOrder[0] = pairs[1];
                        retOrder[1] = pairs[0];
                    }
                    for (i = 0 ; i < NUMBER_OF_HANDCARD ; i++) {
                        if (int8(_handCard[i].value) != pairs[0] && int8(_handCard[i].value) != pairs[1]) {
                            retOrder[2] = int8(_handCard[i].value);
                        }
                        else if (int8(_handCard[i].value) == pairs[0]) {
                            compareSuit = int8(_handCard[i].suit);
                        }
                    }
                }
                else {
                    handValue = HandEnum.OnePair;
                    retOrder[0] = pairs[0];
                    uint256 j = 3;
                    for (i = 0; i < NUMBER_OF_HANDCARD; i++) {
                        if (int8(_handCard[i].value) != pairs[0]) {
                            retOrder[j] = int8(_handCard[i].value);
                            j = j.sub(1);
                        }
                        else {
                            compareSuit = int8(_handCard[i].suit);
                        }
                    }
                }
            }
        }
        return EvaluateHand(handValue, retOrder, compareSuit);
    }

    function _distributionEther(uint256 _winnerPlayer, uint256 avgEther) private onlyOwner {
        for (uint256 i = 0; i < IDToPlayers[_winnerPlayer].bettorLength; i++) {
            IDToPlayers[_winnerPlayer].bettor[i].transfer(avgEther);
        }
    }

    function adminWithdraw(uint256 _withdrawNumber) public onlyOwner {
        require(adminEtherBalance >= _withdrawNumber);
        adminEtherBalance.sub(_withdrawNumber);
        msg.sender.transfer(_withdrawNumber);
    }
}