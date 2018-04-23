pragma solidity ^0.4.21;

contract MoneyBox {
    
    address public charity;
    address public operator;
    
    function MoneyBox () public {}
    
    function () external payable {}
    
    function deleteCharity() {
        if (msg.sender == charity) {
            delete charity;
        }
    }
    
    function deleteOperator() {
        if (msg.sender == operator) {
            delete operator;
        }
    }
    
    function setCharity () {
        if (charity == 0){
            charity = msg.sender;
        }
    }
    
    function setOperator () {
        if (operator == 0){
            operator = msg.sender;
        }
    }
    
    function getBalance () constant returns (uint) {
        if (msg.sender == charity || msg.sender == operator) {
            return this.balance / 1000000000000000000;
        }
    }
    
    function withDraw(uint amount) {
        if (msg.sender == charity || msg.sender == operator) {
            amount *= 1000000000000000000;
            if (this.balance >= amount) {
                msg.sender.transfer(amount);
            }
        }
    }
}