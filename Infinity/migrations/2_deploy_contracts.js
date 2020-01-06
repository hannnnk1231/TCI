const claimable = artifacts.require("Claimable");
const base = artifacts.require("Base");
const pausable = artifacts.require("Pausable");
const infinityGame = artifacts.require("InfinityGame");
const proxy = artifacts.require("Proxy");
const randomness = artifacts.require("Randomness");
const ownable = artifacts.require("Ownable");

module.exports = function(deployer) {
  deployer.deploy(infinityGame);
  deployer.link(infinityGame, base);
  deployer.link(infinityGame, pausable);
  deployer.deploy(pausable);
  deployer.deploy(pausable, ownable);
  deployer.deploy(base).then(function() {
  return deployer.deploy(proxy, base.address);
});
  deployer.deploy(randomness);
  deployer.link(base, claimable);
  deployer.link(randomness, claimable);
  deployer.deploy(claimable);
  deployer.deploy(claimable, ownable);
  deployer.deploy(ownable);
};