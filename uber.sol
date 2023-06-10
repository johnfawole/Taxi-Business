// SPDX-License-Identifier : MIT 

 pragma solidity 0.8.20;

  contract TaxiBusiness {

// create the necessary structs

   struct Participant {
       address addr;
       uint participantBalance;
   }

   struct ProposedCar {
       uint carID;
       uint price;
       uint offerValidTime;
       uint approvalState;
   }

   struct TaxiDriver {
       address payable addr;
       uint taxiDriverSalary;
       uint lastSalaryTimestamp;
       uint approvalState;
   }

// create the variable for admin

   address payable manager;

// this will be the address of the car dealer

   address payable carDealer;

// make a var and array out of the Participant struct

   Participant public participant;
   Participant[] public participants;

// create a map to track everyone who becomes a participant
   mapping (address => bool) public joinedParticipant;
// the amount needed to join the taxi business
   uint public participationFee;

// create variables concerning car purchases

   TaxiDriver public proposedDriver;
   TaxiDriver public taxiDriver;

   ProposedCar public proposedCar;
   ProposedCar public proposedRepurchaseCar; // this is the car in discourse

// declare timing variables

   uint public aMonth;
   uint public sixMonth;

// variables for maintenance and tax 
   uint public fixExpensesForMaintenanceAndTax;
   uint public timestampForFixedExpenses;
   uint public timestampForDividend;
   

   uint public contractBalance;
   uint public ownedCarID;

   constructor () {
    
    manager = payable(msg.sender);

// it should be the case that 10 Ether is for maintenance and tax
    fixExpensesForMaintenanceAndTax = 10 ether;
// participation fee should be 100 ether
    participationFee = 100 ether;

// give numerical value to the timing variable
    aMonth = 720;
    sixMonth = aMonth * 6;
   }

// create the needed modifiers
    modifier onlyManager () {
     require(msg.sender == manager, "this function is too sensitive; only the admin can call");
        _;
    }

    modifier onlyCarDealer () {
     require(msg.sender == carDealer, "check address; only the dealer is permitted");
     _;
    }

    modifier onlyTaxiDriver () {
     require(msg.sender == taxiDriver.addr, "access denied; only the driver is allowed");
     _;
    }

    modifier onlyParticipant () {
      require(joinedParticipant[msg.sender], "only participants, please");
     _;
    }

// put out the setter functions

    function setCarDealer (address payable dealerAddress) public onlyManager {
      carDealer = dealerAddress;
    }

    function setDriver () public onlyManager {
      require(proposedDriver.approvalState > 5, "more than 5 of the participants should approve it");  
      taxiDriver = proposedDriver;
    }

    function join () public payable {
      require(!joinedParticipant[msg.sender], "Error: can only join once");
      require(participants.length <= 10, "max of 10 people");
      require(msg.value >= participationFee, "you cannot join unless you pay");
     
// newParticipant is the new storage space for anyone just joining
// don't use "participant" because we already used that

      Participant memory newParticipant = Participant(msg.sender, 0);
// set the bool in the mapping to false

      joinedParticipant[msg.sender] = true;

// push those who just joined into the newParticipant array
      participants.push(newParticipant);
    }

// add the two variants of fallback
    
    fallback() external payable {}
    receive() external payable {}

// driver proposal and approval functions

    function proposeDriver (address payable driverAddress, uint driverSalary) public onlyManager {
      TaxiDriver memory driverProposed = TaxiDriver(driverAddress, driverSalary, 0, 0);
      proposedDriver = driverProposed;
    }

    function approveDriver() public {
       proposedDriver.approvalState += 1;
    }

    function getSalary() public payable onlyTaxiDriver{
      require(taxiDriver.taxiDriverSalary > 0, "must have something");

      taxiDriver.addr.transfer(taxiDriver.taxiDriverSalary);
      taxiDriver.taxiDriverSalary = 0;
    }

    function paySalary(uint a_driverSalary) public payable onlyManager {
       taxiDriver.taxiDriverSalary += a_driverSalary;
       taxiDriver.lastSalaryTimestamp = uint(block.timestamp);
    }

  }
