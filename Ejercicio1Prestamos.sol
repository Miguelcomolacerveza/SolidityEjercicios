
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;
 
 
 // Contract in process..... Sorry for the inconvinience ;)
 contract LoanBase {

     error notEnoughFunds();

     event loanCreated();
     event loanApproved();

     struct Loan {
         address provider;
         address borrower;
         uint256 amount;
         uint256 loanInstallment;
         uint256 expirationDate;
         bool approved;    
     }

     modifier onlyProvider(uint _loanID) {
      require(msg.sender == loans[_loanID].provider);
      _;
     }

     mapping(address => uint256) balances;
     mapping(uint256 => Loan) loans;
     uint256 loanID;

     function setLoan(
         address _borrower,
         uint256 _amount,
         uint256 _loanInstallment,
         uint256 _expirationDate
     ) public {
         loans[loanID].provider = _borrower;
         loans[loanID].amount = _amount;
         loans[loanID].loanInstallment = _loanInstallment;
         loans[loanID].expirationDate = _expirationDate;
         loanID++;

         emit loanCreated();
     }

     function getLoan(uint _loanID) public view returns(Loan memory loan){
         return loans[_loanID];
     }

     function approveLoan(uint256 _loanID) public onlyProvider(_loanID) {
         loans[_loanID].approved = true;
         emit loanApproved();

     }

     function calculatePercentage(uint256 _percentage, uint256 _amount) public pure returns(uint256) {
         uint256 totalPercentage = (_percentage * _amount) / 100;
         return totalPercentage;
     }
 }
