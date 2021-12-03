pragma solidity ^0.4.24;

contract CampaignFactory {
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaigns() public view returns(address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    uint public contributions;
    
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    Request[] public requests;
    
    constructor(uint mimimum, address creator) public {
        manager = creator;
        minimumContribution = mimimum;
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function contribute() public payable {
        contributions += msg.value;
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function createRequest(string _description, uint _value, address _recipient) public restricted {
        Request memory newRequest = Request({
            description: _description,
            value: _value,
            recipient: _recipient,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender]);
        require(!requests[index].approvals[msg.sender]);
        
        requests[index].approvals[msg.sender] = true;
        requests[index].approvalCount ++;
    }

    function finalizeRequest(uint index) public restricted{
        require(!requests[index].complete);
        require(requests[index].approvalCount * 2 > approversCount);
        
        requests[index].complete = true;
        requests[index].recipient.transfer(requests[index].value);
    }
}
