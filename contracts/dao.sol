// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "token.sol";

contract Source {
    uint16 public numberOfDelegates=5;
    AIHKToken public token;
    address[] public alreadyDelegated;
    mapping(address=>uint256)public candidates;
    mapping(address=>bool) public hasDelegated;
    mapping(address=>bool) public isCandidate;
    uint8 public requiredNumberOfReferralsForNewMembers=4;
    mapping(address=>mapping(address=>uint256)) public constituentsPerCandidate;
    mapping(address=>mapping(address=>uint256)) public picksPerMember;
    mapping(address=>Member) public members;
    mapping(address=>uint256) public lastReferralTime;
    mapping(address=>uint8)public newMemberReferralsNumber;
    mapping(address=>mapping(address=>bool)) public newMemberReferralsID;
    Spending[] public expenditures;

    constructor (address repTokenAddress) {
        token = AIHKToken(repTokenAddress);
    }

    struct Spending{
        address author;
        address recipient;
        uint256 amount;
        address[] approvals;
    }

    struct Member{
        uint256 lastStake;
        address[] picks;
    }

    function submitSpendingProposal(address receiver, uint256 _amount) external {
        require (token.balanceOf(address(msg.sender))>0, "Only members can propose spendings.");
        Spending memory s;
        s.author=msg.sender;
        s.recipient=receiver;
        s.amount=_amount;
        expenditures.push(s);
    }
  

    function referNewMember(address newMember) external {
        require (token.balanceOf(address(msg.sender))>0, "You are not a member" );
        require (newMemberReferralsID[newMember][msg.sender]!=true,"You already referred this member");
        newMemberReferralsNumber[newMember]+=1;
        newMemberReferralsID[newMember][msg.sender]=true;
    }

    function claimMemberShip(address newMember)public{
        require (token.balanceOf(address(msg.sender))==0,"This is an existing member" );
        if (newMemberReferralsNumber[newMember]>=requiredNumberOfReferralsForNewMembers){
            token.mint(newMember,10^18);
        }
    }

    function submitCandidacy()public{
        require (token.balanceOf(address(msg.sender))>0, "You are not a member");
        require (isCandidate[msg.sender]==false, "You're already a candidate");
        isCandidate[msg.sender]=true;
        candidates[msg.sender]=token.balanceOf(msg.sender);
    }
    
    function proposeToChangeNumberOfDelegates(uint8 newNumber)public returns(uint8){
        require (token.balanceOf(address(msg.sender))>0, "You are not a member");
        return newNumber;
    }

    function executeExpenditure(uint256 whichOne, address paymentTokenAddress)external{
        ERC20 paymentToken=ERC20(paymentTokenAddress);
        paymentToken.transfer(expenditures[whichOne].recipient, expenditures[whichOne].amount);

    }

    function revokeSupport()public{
        require (token.balanceOf(address(msg.sender))>0, "You are not a member");
        require (hasDelegated[msg.sender]==true, "You haven't delegated your vote");
        for  (uint8 i=0;i<members[msg.sender].picks.length;i++){
            candidates[members[msg.sender].picks[i]]=candidates[members[msg.sender].picks[i]]-members[msg.sender].lastStake;
        }
        hasDelegated[msg.sender]=false;
    }


    function pickRepresentatives (address[] memory reps)external{
        require (token.balanceOf(address(msg.sender))>0, "You are not a member");
        require (hasDelegated[msg.sender]==false, "You already delegated your vote");
        require (reps.length<16,"Can't approve more than 16 candidates");
        uint256 addedStake=token.balanceOf(address(msg.sender)) / reps.length;
        members[msg.sender].picks=reps;
        members[msg.sender].lastStake=addedStake;
        for (uint8 i=0; i<reps.length; i++)  {
            require ( isCandidate[reps[i]]==true,"Not a valid candidate");
            candidates[reps[i]]+=addedStake;
            constituentsPerCandidate[reps[i]][msg.sender]=addedStake;
            picksPerMember[msg.sender][reps[i]]=addedStake;
        } 
        hasDelegated[msg.sender]=true;
    }

    function approveSpendingProposal(uint256 whichProposal) public {
        // sort candidates and require that msg.sender is part of top <numberOfDelegates>
        bool alreadyApproved=false;
        for (uint32 i=0;i<expenditures[whichProposal].approvals.length;i++){
            if (expenditures[whichProposal].approvals[i]==msg.sender){
                alreadyApproved=true;
            }
        }
        if (!alreadyApproved){  
            expenditures[whichProposal].approvals.push(msg.sender);
        }
    }

    //change from bubblesort to a more gas-efficient method
    function bubbleSort(uint256[] memory arr) public returns (uint256[] memory){
        uint256 length=arr.length;
        for (uint256 i=0;i<length-1;i++){
            for (uint256 j=0;j<length-1;j++){
                if (arr[j]>arr[j+1]){
                    uint256 currentValue=arr[j];
                    arr[j]=arr[j+1];
                    arr[j+1]=currentValue;
                }
            }
        }
        return arr;
    }

}