pragma solidity ^0.4.21;

contract Registry {
    
    struct DropBox {
        address charity;
        address operator;
        address owner;
        string latitude;
        string longitude;
        string time;
        uint balance;
        bool isSet;
    }

    struct Charity {
        string name;
        uint charityNumber;
        bool isSet;
        mapping(address => DropBox) boxMap;
    }

    struct Operator {
        string name;
        uint phoneNumber;
        string operatorType;
        bool isSet;
        mapping(address => DropBox) boxMap;
    }

    struct Owner {
        string name;
        string latitude;
        string longitude;
        bool isSet;
    }

    mapping(address => DropBox) public boxMap;
    mapping(address => Charity) public charityMap;
    mapping(address => Operator) public operatorMap;
    mapping(address => Owner) public ownerMap;

    constructor() public {}

    function donate (address dropBoxAddress) payable public returns (bool) {
        if(boxMap[dropBoxAddress].isSet) {
            boxMap[dropBoxAddress].balance += msg.value;
            return false;
        }
        
        return true;
    }
    
    function withdraw (address dropBoxAddress) public returns (bool) {
        if(boxMap[dropBoxAddress].isSet) {
            DropBox memory dropBox = boxMap[dropBoxAddress];
            if ((charityMap[msg.sender].isSet && dropBox.charity == msg.sender) 
                || (operatorMap[msg.sender].isSet && dropBox.operator == msg.sender)) {
                
                address receiver = msg.sender;
                uint amount = dropBox.balance;
                receiver.transfer(amount);
                boxMap[dropBoxAddress].balance = 0;
                return true;
            } else {
                return false;
            }
        }
    }

    function createDropBox (
        string latitude,
        string longitude,
        string time,
        address dropBoxAddress) public returns (bool) {
            
        DropBox memory dropBox = DropBox (
            {
            charity: address(0),
            operator: address(0),
            owner: address(0),
            latitude: latitude,
            longitude: longitude,
            time: time,
            balance: 0,
            isSet: true
            }
        );
        boxMap[dropBoxAddress] = dropBox;
        return true;
    }

    function createCharity (string name, uint charityNumber) public returns (bool) {
        
        charityMap[msg.sender] = Charity (
            {
            name: name,
            charityNumber: charityNumber,
            isSet: true
            }
        );
        return true;
    }
    
    function createOperator (
        string name,
        uint phoneNumber,
        string operatorType) public returns (bool)  {

        operatorMap[msg.sender] = Operator (
            {
            name: name,
            phoneNumber: phoneNumber,
            operatorType: operatorType,
            isSet: true
            }
        );
        
        return true;
    }

    function createOwner (string name, string latitude, string longitude) public returns (bool) {

        ownerMap[msg.sender] = Owner (
            {
            name: name,
            latitude: latitude,
            longitude: longitude,
            isSet: true
            }
        );
        
        return true;
    }
    
    function setCharity (address dropBoxAddress) public returns (bool) {
        // check drop box and charity exist and drop box currently has no associated charity
        if (boxMap[dropBoxAddress].isSet
        && charityMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].charity == 0)) {
            boxMap[dropBoxAddress].charity = msg.sender;
            return true;
        }
        return false;
    }
    
    function setOperator (address dropBoxAddress) public returns (bool) {
        // check drop box and operator exist and drop box currently has no associated operator
        if (boxMap[dropBoxAddress].isSet
        && operatorMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].operator == 0)) {
            boxMap[dropBoxAddress].operator = msg.sender;
            return true;
        }
        return false;
    }
    
    function setOwner (address dropBoxAddress) public returns (bool) {
        // check drop box and owner exist and drop box currently has no associated owner
        if (boxMap[dropBoxAddress].isSet
        && ownerMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].owner == 0)) {
            boxMap[dropBoxAddress].owner = msg.sender;
            return true;
        }
        return false;
    }
    
    function changeLocation (address dropBoxAddress, string latitude, string longitude) public returns (bool) {
        boxMap[dropBoxAddress].latitude = latitude;
        boxMap[dropBoxAddress].longitude = longitude;
        return true;
    }
    
    function changeTime (address dropBoxAddress, string time) public returns (bool) {
        boxMap[dropBoxAddress].time = time;
        return true;
    }

    function charityUnregisterBox (address dropBoxAddress) public returns (bool) {
        delete charityMap[msg.sender].boxMap[dropBoxAddress];
        delete boxMap[dropBoxAddress].charity;
        return true;
    }
    
    function operatorUnregisterBox (address dropBoxAddress) public returns (bool) {
        delete operatorMap[msg.sender].boxMap[dropBoxAddress];
        delete boxMap[dropBoxAddress].operator;
        return true;
    }

    function ownerUnregisterBox (address dropBoxAddress) public returns (bool) {
        delete boxMap[dropBoxAddress].owner;
        return true;
    }
    
    function deleteDropBox (address dropBoxAddress) public returns (bool) {
        delete boxMap[dropBoxAddress];
        return true;
    }
    
    function deleteCharity (address charityAddress) public returns (bool) {
        delete charityMap[charityAddress];
        return true;
    }
    
    function deleteOperator (address operatorAddress) public returns (bool) {
        delete operatorMap[operatorAddress];
        return true;
    }
    
    function deleteOwner (address ownerAddress) public returns (bool) {
        delete ownerMap[ownerAddress];
        return true;
    }    
}