//const SimpleStorage = artifacts.require("SimpleStorage");
const Token=artifacts.require("Token")

module.exports = function (deployer,NAME,SYMBOL,INITIALSUPPLY) {
  //deployer.deploy(SimpleStorage);
  deployer.deploy(Token,"Omega","HPU",10000);

};
