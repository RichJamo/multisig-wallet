pragma solidity 0.7.5;
pragma abicoder v2;

import "./Ownable.sol";

contract Wallet is Ownable{
    
    mapping(address => uint) balance;
   
    event depositDone(uint amount, address indexed depositedTo);
    event TransferMade(uint amount, address indexed sentFrom, address indexed sentTo);
   
    address owner1;
    address owner2;
    address owner3;
    uint sigsNeeded;
    
    constructor(address _owner1, address _owner2, address _owner3, uint _sigsNeeded) { //gets run only the first time the contract gets run? i.e. at 'setup'
       //owner = msg.sender;
       owner1 = _owner1;
       owner2 = _owner2;
       owner3 = _owner3;
       sigsNeeded = _sigsNeeded;
    }
    
    function deposit () public payable returns (uint) { //this allows anyone to deposit
       balance[msg.sender] += msg.value;
       emit depositDone(msg.value, msg.sender);
       return balance[msg.sender];
    }
   
    //function withdraw(uint amount) public returns (uint){
    //    require  (balance[msg.sender] >= amount, "Balance not sufficient"); //make sure this address has sufficient balance at this contract
    //    msg.sender.transfer(amount);    //transfer function has in-built error throwing
    //    balance[msg.sender] -= amount;
    //    return balance[msg.sender];
   //}
   
    function getBalance() public view returns (uint) {
       return balance[msg.sender];
    }
   
    function transfer (address recipient, uint amount) public {
       require(balance[msg.sender] >= amount, "Balance not sufficient"); // if not the case, revert happens, transaction will not happen
       require(msg.sender != recipient, "Don't transfer money to yourself");
       
       uint previousSenderBalance = balance[msg.sender];
       
        _transfer(msg.sender, recipient, amount);
       emit TransferMade(amount, msg.sender, recipient);
       
       //governmentInstance.addTransaction{value: 1 ether} (msg.sender, recipient, amount);
       
       //gwei = 10^9 
       //ether = 10^18 
       
       assert(balance[msg.sender] == previousSenderBalance - amount);
    }
   
    function _transfer (address from, address to, uint amount) private {
       balance[from] -= amount;
       balance[to] += amount;
    } 
}
