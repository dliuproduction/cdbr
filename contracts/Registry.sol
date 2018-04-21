pragma solidity ^0.4.21;

contract Registry {
    
    // address emptyAddress = 0x0000000000000000000000000000000000000000;
    mapping(address => DropBox) emptyMap;
    
    struct DropBox {
        address charity;
        address operator;
        address owner;
        string location;
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
        string location;
        bool isSet;
    }

    mapping(address => DropBox) public boxMap;
    mapping(address => Charity) public charityMap;
    mapping(address => Operator) public operatorMap;
    mapping(address => Owner) public ownerMap;

    // constructor
    function Registry() public {}

    /* public flow */
    
    function donate (address dropBoxAddress) payable {
        if(boxMap[dropBoxAddress].isSet) {
            DropBox memory dropBox = boxMap[dropBoxAddress];
            dropBox.balance += msg.value;
        }
    }
    
    function withdraw (address dropBoxAddress) public {
        if(boxMap[dropBoxAddress].isSet) {
            DropBox memory dropBox = boxMap[dropBoxAddress];
            if ((charityMap[msg.sender].isSet && dropBox.charity == msg.sender) 
                || (operatorMap[msg.sender].isSet && dropBox.operator == msg.sender)) {
                
                address receiver = msg.sender;
                uint amount = dropBox.balance;
                receiver.transfer(amount);
                dropBox.balance = 0;
                
            } else {
                throw;
            }
        }
    }

    function createDropBox (
        string location,
        string time,
        address dropBoxAddress) public {
            
        DropBox memory dropBox = DropBox (
            {
            charity: address(0),
            operator: address(0),
            owner: address(0),
            location: location,
            time: time,
            balance: 0,
            isSet: true
            }
        );
        boxMap[dropBoxAddress] = dropBox;
    }

    function createCharity (string name, uint charityNumber) public {
        
        charityMap[msg.sender] = Charity (
            {
            name: name,
            charityNumber: charityNumber,
            isSet: true
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
            operatorType: operatorType,
            isSet: true
            }
        );
    }

    function createOwner (string name, string location) public {

        ownerMap[msg.sender] = Owner (
            {
            name: name,
            location: location,
            isSet: true
            }
        );
    }
    
    function setCharity (address dropBoxAddress) public {
        // check drop box and charity exist and drop box currently has no associated charity
        if (boxMap[dropBoxAddress].isSet
        && charityMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].charity == 0)) {
            boxMap[dropBoxAddress].charity = msg.sender;
        }
    }
    
    function setOperator (address dropBoxAddress) public {
        // check drop box and operator exist and drop box currently has no associated operator
        if (boxMap[dropBoxAddress].isSet
        && operatorMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].operator == 0)) {
            boxMap[dropBoxAddress].operator = msg.sender;
        }
    }
    
    function setOwner (address dropBoxAddress) public {
        // check drop box and owner exist and drop box currently has no associated owner
        if (boxMap[dropBoxAddress].isSet
        && ownerMap[msg.sender].isSet
        && (boxMap[dropBoxAddress].owner == 0)) {
            boxMap[dropBoxAddress].owner = msg.sender;
        }
    }
    
    function changeLocation (address dropBoxAddress, string location) public {
        boxMap[dropBoxAddress].location = location;
    }
    
    function changeTime (address dropBoxAddress, string time) public {
        boxMap[dropBoxAddress].time = time;
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