

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

/*
 This contract is made to provide loans to customer through a "bank".
*/
 
 contract LoanBase {

    address owner;

     constructor() {
         owner = msg.sender;
     }

     error NoAccessToThisAccount();

     event loanCreated();
     event loanApproved();

     enum Status {
         PENDING,
         APPROVED,
         CANCELED
     }

     // @param provider -> address of the provider of the loan
     // @param borrower -> address of the borrower of the loan
     // @param amount -> full amount of the requested loan
     // @param loanInstallment -> amount of each single payment to repay the loan
     // @param expirationDate -> Deadline to repay the loan
     // @param status -> Status type var used as a container of the status of the loan

     struct Loan {
         address provider;
         address borrower;
         uint256 amount;
         uint256 loanInstallment;
         uint256 expirationDate;
         Status status;
     }

     modifier onlyOwner(uint _loanID) {
      require(msg.sender == owner);
      _;
     }
     
     mapping(address => uint256) balances; // mapping with all the customer´s balances
     mapping(uint256 => Loan) loans; // mapping with all the customer´s loans
     uint256 loanID; // Counter to identify each loan

     function setLoan(
         uint256 _amount,
         uint256 _loanInstallment,
         uint256 _expirationDate
     ) public {
         loans[loanID].borrower = msg.sender;
         loans[loanID].amount = _amount;
         loans[loanID].loanInstallment = _loanInstallment;
         loans[loanID].expirationDate = _expirationDate * 86400;
         loanID++;

         emit loanCreated();
     }

     function getLoan(uint _loanID) public view returns(Loan memory loan){
         return loans[_loanID];
     }

     function approveLoan(uint256 _loanID) public onlyOwner(_loanID) {
         // Once the bank has approved the loan, we:

         // Modify the status to approved
         loans[_loanID].status = Status.APPROVED;
         // As the bank has approved the loan, we set the expiration date based on this action
         loans[_loanID].expirationDate += block.timestamp;
         // Set the address of the bank as a provider
         loans[_loanID].provider = owner;
         // Add the loan amount to the customer´s account
         balances[loans[_loanID].borrower] += loans[_loanID].amount;
         emit loanApproved();
     }

     function getBalance(address _account) public view returns(uint256) {
         if(msg.sender != _account) revert NoAccessToThisAccount();
         return balances[_account];
     }
 }
