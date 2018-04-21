pragma solidity ^0.4.21;

contract Registry {

    struct DropBox {
        address charity;
        address operator;
        address owner;
        string location;
        string time;
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
        string time,
        address dropBoxAddress) public {
            
        DropBox memory dropBox = DropBox (
            {
            charity: charity,
            operator: operator,
            owner: owner,
            location: location,
            time: time
            }
        );
        
        boxMap[dropBoxAddress] = dropBox;
        
        charityMap[charity].boxMap[dropBoxAddress] = dropBox;
        operatorMap[operator].boxMap[dropBoxAddress] = dropBox;
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
    
    function deleteDropBox (address dropBoxAddress) public {
        delete boxMap[dropBoxAddress];
    }
    
    function deleteCharity (address charityAddress) public {
        delete charityMap[charityAddress];
    }
    
    function deleteOperator (address operatorAddress) public {
        delete operatorMap[operatorAddress];
    }
    
    function deleteOwner (address ownerAddress) public {
        delete ownerMap[ownerAddress];
    }
    
    function changeCharity (address dropBoxAddress, address newCharityAddress) public {
        boxMap[dropBoxAddress].charity = newCharityAddress;
    }
    
    function changeOperator (address dropBoxAddress, address newOperatorAddress) public {
        boxMap[dropBoxAddress].operator = newOperatorAddress;
    }
    
    function changeOwner (address dropBoxAddress, address newOwnerAddress) public {
        boxMap[dropBoxAddress].owner = newOwnerAddress;
    }
    
    function changeLocation (address dropBoxAddress, string newLocation) public {
        boxMap[dropBoxAddress].location = newLocation;
    }
    
    function changeTime (address dropBoxAddress, string newTime) public {
        boxMap[dropBoxAddress].location = newTime;
    }

    function charityUnregisterBox (address charityAddress, address dropBoxAddress) public {
        delete charityMap[charityAddress].boxMap[dropBoxAddress];
        delete boxMap[dropBoxAddress].charity;
    }
    
    function operatorUnregisterBox (address operatorAddress, address dropBoxAddress) public {
        delete operatorMap[operatorAddress].boxMap[dropBoxAddress];
        delete boxMap[dropBoxAddress].operator;
    }

    function ownerUnregisterBox (address ownerAddress, address dropBoxAddress) public {
        delete boxMap[dropBoxAddress].owner;
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

    // function notifyCharity(address charityAddress, string message) private {
    // 
    // }
   

}