pragma solidity ^0.4.22;

contract RegistryInterface {
  
  struct DropBox {
    address charity;
    address operator;
    address owner;
    string location;
    string[] pickupTimes;
  }

  struct Charity {
    string name;
    uint charityNumber;
    mapping(address => DropBox) public boxMap;
  }

  struct Operator {
    string name;
    string address;
    uint phoneNumber;
    string type;
    mapping(address => DropBox) public boxMap;
  }

  struct Owner {
    string name;
    string address;
  }

  mapping(address => DropBox) public boxMap;
  mapping(address => Charity) public charityMap;
  mapping(address => Operator) public operatorMap;
  mapping(address => Owner) public ownerMap;

  function getDropBox (address _dropBoxAddress);

  function getCharity (address _charityAddress);

  function getOperator (address _operatorAddress);

  function getOwner (address _ownerAddress);

  function setLocation (DropBox dropBox, string newLocation);

  function setOperator (DropBox dropBox, operator newOperator);

  function changeOperator(DropBox dropBox, address newOperatorAddress) public;

  function changeLocation(DropBox dropBox, string newLocation) public;

  function unregisterBox(Operator operator, address _dropBoxAddress) public;

  function notifyCharity();

  function changeOwner (DropBox dropBox, address _newOwnerAddress);

}