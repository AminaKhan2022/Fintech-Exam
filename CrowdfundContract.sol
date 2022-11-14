// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//Create crowdfund contract and declare variable types
contract CrowdFundPlatform{
                            struct Project{
                            uint256 id;
                            uint256 targetAmount;
                            uint256 accumulatedAmount;
                            string name;
                            address owner;
                            address recipient;
                          }

//Store values
mapping(address => mapping(uint256 => uint256)) public donationsPerUserPerProject;
mapping(address => uint256) public usersTotalDonations;

mapping(uint256 => Project) public projects;

mapping(uint256 => uint256) public balances;
uint256 public numberOfProjects = 0;

//Function 1: Create Project

function createProject(string memory _name, address _recipient, uint256 _targetAmount) public {

    //Check all params are valid
require(_recipient != address(0), "Cannot be address zero");

    //Create project object and set variables
projects[numberOfProjects] = Project({id: numberOfProjects, targetAmount: _targetAmount, accumulatedAmount: 0, 
name: _name,owner: msg.sender,recipient: _recipient});

    //Increment number of projects
numberOfProjects++;
} 

//Function 2: Donate

function donate(uint256 _projectId) public payable {

require(_projectId <= numberOfProjects, "Invalid ID");

projects[_projectId].accumulatedAmount += msg.value;
balances[_projectId] += msg.value;
usersTotalDonations[msg.sender] += msg.value;
donationsPerUserPerProject[msg.sender][_projectId] += msg.value;
if(projects[_projectId].accumulatedAmount >= projects[_projectId].targetAmount){

//Call withdraw
withdraw(_projectId);
}
}

//Function 3: Withdraw

function withdraw(uint256 _projectId) internal {

Project memory tempProject = projects[_projectId];

balances[_projectId] -= tempProject.accumulatedAmount;
address targetRecipient = tempProject.recipient;
uint256 amountPayable = tempProject.accumulatedAmount;

(bool sent, ) = targetRecipient.call{value: amountPayable}("");
require(sent, "Failed to send Ether");
}

//Allow the receipt of Eth
receive() external payable {}

}

