pragma solidity ^0.4.23;

contract MoneyBox {
    
    address public charity;
    address public operator;
    
    function MoneyBox () public {}
    
    function () external payable {}
    
    function deleteCharity() public {
        if (msg.sender == charity) {
            delete charity;
        }
    }
     
    function deleteOperator() public {
        if (msg.sender == operator) {
            delete operator;
        }
    }
    
    function setCharity () public {
        if (charity == 0){
            charity = msg.sender;
        }
    }
    
    function setOperator () public {
        if (operator == 0){
            operator = msg.sender;
        }
    }
    
    function getBalance () constant public returns (uint) {
        if (msg.sender == charity || msg.sender == operator) {
            return this.balance;
        }
    }
    
    function withDraw(uint weiAmount) public {
        if (msg.sender == charity || msg.sender == operator) {
            if (this.balance >= weiAmount){
                msg.sender.transfer(weiAmount);
            }
        }
    }
}