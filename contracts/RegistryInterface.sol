pragma solidity ^0.4.23;

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
    mapping(address => DropBox) boxMap;
  }

  struct operator {
    string name;
    string operatorAddress;
    uint phoneNumber;
    string operatorType;
    mapping(address => DropBox) boxMap;
  }

  struct Owner {
    string name;
    string ownerAddress;
  }

  mapping(address => DropBox) public boxMap;
  mapping(address => Charity) public charityMap;
  mapping(address => operator) public operatorMap;
  mapping(address => Owner) public ownerMap;

  function getDropBox (address _dropBoxAddress) external;

  function getCharity (address _charityAddress) external;

  function getOperator (address _operatorAddress) external;

  function getOwner (address _ownerAddress) external;

  function setLocation (address _dropBoxAddress, string _newLocation) external;

  function changeOperator(address _dropBoxAddress, address _newOperatorAddress) external;

  function changeLocation(address _dropBoxAddress, string _newLocation) external;

  function unregisterBox(address _operatorAddress, address _dropBoxAddress) external;

  function notifyCharity() private;

  function changeOwner (address _dropBoxAddress, address _newOwnerAddress) external;

}