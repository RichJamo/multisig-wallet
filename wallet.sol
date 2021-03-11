pragma solidity 0.7.5;
pragma abicoder v2;

import "./Ownable.sol";

contract Wallet is Ownable{
    address[] public owners;
    
    struct Transfer{
        uint transferID;
        address payable recipient;
        uint amount;
        uint noOfApprovals;
    }
    
    Transfer[] transferRequests;
    
    mapping(address => mapping(uint=>bool)) approvals; //a double mapping - remember it's similar to a dictionary!
   
    event depositDone(uint amount, address indexed depositedTo);
    event TransferRequestMade(uint amount, address indexed sentTo, uint transferID);

    uint sigsNeeded;
    uint balance;
    
    constructor(address _owner1, address _owner2, address _owner3, uint _sigsNeeded) { //gets run only the first time the contract gets run? i.e. at 'setup'
       //owner = msg.sender;
       owners.push(_owner1); //make it possible to have as many owners as you like
       owners.push(_owner2);
       owners.push(_owner3);
       sigsNeeded = _sigsNeeded;
    }
    
    function approve (uint transferID, bool yesOrNo) public payable {
        //require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == owner3); //change this to check array rather!
        approvals[msg.sender][transferID] == yesOrNo; //process the approval that's just come in
        
        transferRequests[transferID].noOfApprovals += 1; //increase number of approvals by 1 - what if it was marked false??
        if (transferRequests[transferID].noOfApprovals >= sigsNeeded) { //check if enough approvals
            address payable payableRecipient = transferRequests[transferID].recipient; //make the address payable
            payableRecipient.transfer(transferRequests[transferID].amount); //makes the transfer if there are enough sigs
        }
    }
    
    function deposit () public payable returns (uint) { //this allows anyone to deposit
       balance += msg.value;
       emit depositDone(msg.value, msg.sender);
       return balance;
    }
   
    function getBalance() public view returns (uint) {
       return balance; // how do I return the total balance of the wallet??
    }
   
    function transfer (address payable _recipient, uint _amount) public {
       require(balance >= _amount, "Balance not sufficient"); // if not the case, revert happens, transaction will not happen
       //require(msg.sender == owner1 || msg.sender == owner2 || msg.sender == owner3);
       uint transferID = transferRequests.length;
       
       Transfer memory t; //create a Transfer struct t
       t.recipient = _recipient; //put data into t - could I do this in one line?
       t.amount = _amount;
       t.transferID = transferID;
       t.noOfApprovals = 0;
       
       transferRequests.push(t); //add t to the the array
       emit TransferRequestMade(_amount, _recipient, transferID); //emit that a transfer request has been made
       balance -= _amount; //decrease balance by the amount of the request - should this be done here? or only later when the transfer is actually made?
    }
}
