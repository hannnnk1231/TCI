const MagicToken = artifacts.require("./MagicToken.sol");

module.exports = function(deployer) {
  deployer.deploy(MagicToken);
};
