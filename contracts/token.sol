// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AIHKToken is ERC20 {
    address public owner;
    address public DAO;

    constructor(string memory name, string memory symbol) ERC20 (name, symbol)  {
        // _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override pure {
        require(false, "non-transferrable");
        sender;
        recipient;
        amount;
    }

    function addMember(address newMember)external onlyDAO{
        _mint(newMember, 10^18);
    }

    function mint(address holder, uint256 amount) external onlyDAO {
        _mint(holder, amount);
    }

    function burn(address holder, uint256 amount) external onlyDAO {
        _burn(holder, amount);
    }

    function changeDAO(address newDAO) external onlyDAOorOwner {
        DAO = newDAO;
    }

    function revokeOwnershipWithoutReplacement() external onlyDAOorOwner {
        owner = address(0x0);
    }

    function getDAO() external view returns(address){
        return DAO;
    }

    modifier onlyDAO() {
        require(msg.sender==DAO, "only DAO");
        _;
    }

    modifier onlyDAOorOwner {
        require(msg.sender==owner || msg.sender==DAO, "only DAO or Owner");
        _;
    }
  
}




