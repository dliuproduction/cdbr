pragma solidity ^0.4.21;

contract Registry {

    struct DropBox {
        address charity;
        address operator;
        address owner;
        string location;
        string pickupTimes;
    }

    struct Charity {
        string name;
        uint charityNumber;
        mapping(address => DropBox) boxMap;
    }

    struct Operator {
        string name;
        uint phoneNumber;
        string operatorType;
        mapping(address => DropBox) boxMap;
    }

    struct Owner {
        string name;
        string location;
    }

    mapping(address => DropBox) public boxMap;
    mapping(address => Charity) public charityMap;
    mapping(address => Operator) public operatorMap;
    mapping(address => Owner) public ownerMap;

    // constructor
    function Registry() public {}

    /* public flow */

    function createDropBox (
        address charity, 
        address operator,
        address owner,
        string location,
        string pickupTimes,
        address dropBoxAddress) public {

        boxMap[dropBoxAddress] = DropBox (
            {
            charity: charity,
            operator: operator,
            owner: owner,
            location: location,
            pickupTimes: pickupTimes
            }
        );
    }

    function createCharity (string name, uint charityNumber) public {

        charityMap[msg.sender] = Charity (
            {
            name: name,
            charityNumber: charityNumber
            }
        );
    }
    
    function createOperator (
        string name,
        uint phoneNumber,
        string operatorType) public {

        operatorMap[msg.sender] = Operator (
            {
            name: name,
            phoneNumber: phoneNumber,
            operatorType: operatorType
            }
        );
    }

    function createOwner (string name, string location) public {

        ownerMap[msg.sender] = Owner (
            {
            name: name,
            location: location
            }
        );
    }
    
    // function getOwner (address _ownerAddress) private returns (Owner) {
    //     return ownerMap[_ownerAddress];
    // }

    // function getDropBox (address _dropBoxAddress) private returns (DropBox) {
    //     return boxMap[_dropBoxAddress];
    // }

    // function getCharity (address _charityAddress) private returns (Charity) {
    //     return charityMap[_charityAddress];
    // }

    // function getOperator (address _operatorAddress) private returns (operator) {
    //     return operatorMap[_operatorAddress];
    // }

    // function setLocation (address _dropBoxAddress, string _newLocation) external;

    // function changeOperator(address _dropBoxAddress, address _newOperatorAddress) external;

    // function changeLocation(address _dropBoxAddress, string _newLocation) external;

    // function unregisterBox(address _operatorAddress, address _dropBoxAddress) external;

    // function notifyCharity() private;

    // function changeOwner (address _dropBoxAddress, address _newOwnerAddress) external;

}