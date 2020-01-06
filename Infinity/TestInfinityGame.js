const InfinityGame = artifacts.require("InfinityGame");

//import { inTransaction } from "./helper/expectEvent";
import { reverting } from "./helper/shouldFail";

let newPlayerLimit = 0.2;
let newHouseFee = 5;

//let betAmount = web3.toWei("0.1", "ether");
//let invalidBetNumber = web3.toWei("1", "ether");

contract('InfinityGame', function (accounts) {
    const [owner, player1, player2, anyone] = accounts;

    before(async function () {

        // deploy new contract with correct input parameters
        infinityGame = await InfinityGame.new();

        // start first round
        const tx = await infinityGame.createGame();

        let testPlayersID = [];
        let testGameID = tx.logs.find(function (e) {
            if (e.event === "CreatGame") {
                return e[gameID];
            }
        });

        assert.notEqual(await infinityGame.IDToGames(testGameID).gameID, 0);

        tx.logs.find(function (e) {
            if (e.event === "CreatePlayer") {
                testPlayersID.push(e[playerID]);
            }
        });

        for(i in testPlayersID){
            assert.notEqual(await infinityGame.IDToPlayers(i).playerID, 0);
        }

        console.log(testPlayersID);
        console.log(testGameID);

    });

    describe('Basic variables settings', function () {
        it("owner should be able to set new player limit", async function () {
            await infinityGame.setPlayerLimit(newPlayerLimit);
            assert.equal(await infinityGame.playerLimit(), newPlayerLimit);
        });

        it("owner should be able to set new player limit", async function () {
            await infinityGame.setHouseFee(newHouseFee);
            assert.equal(await infinityGame.houseFee(), newHouseFee);
        });

        it("non owner should not be able to set any game variable", async function () {
            await reverting(infinityGame.setPlayerLimit(newPlayerLimit, { from: anyone }));
            await reverting(infinityGame.setHouseFee(newHouseFee, { from: anyone }));
        });
    });

});  