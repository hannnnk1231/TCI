const zombiefeed = artifacts.require("ZombieFeeding");
const zombiefactory = artifacts.require("ZombieFactory");

module.exports = function(deployer) {
  deployer.deploy(zombiefactory);
  deployer.link(zombiefactory, zombiefeed);
  deployer.deploy(zombiefeed);
};
