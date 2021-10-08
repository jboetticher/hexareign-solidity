//SPDX-License-Identifier: Attribution Assurance License
pragma solidity ^0.8.4;
 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HEXRToken is ERC20Pausable, Ownable {
    
    // The number of applications that have had tokens allocated to it.
    uint8 public dAppCount;
    
    // The addresses of the dApps that have had tokens allocated to it.
    address[8] internal dAppAddresses;
    
    // The time a dApp was last allocated 1 billion tokens.
    uint public lastDAppAllocated;
    
    constructor() ERC20("Hexoreign", "HEXR") 
    {
        // Mints 8 billion tokens for this contract to keep hold of.
        _mint(address(this), 8000000000 ether);
        
        // Gives the creator 10,000,000 tokens: ~.12% of total token supply.
        // Creator can use it to fund ecosystem projects or just fund development.
        _mint(_msgSender(), 10000000 ether);
    }
    
    
    
    function addApplication(address newDApp) public onlyOwner {
        // Ensures that it's not the 0 address.
        require(newDApp != address(0), "ERC20: application to add is the zero address");
        
        // There can only be a maximum of 8 applications.
        require(dAppCount < 8);
    
        // Makes sure that there is a 6 month difference between the first 2 and the next applications.
        // Stops a massive influx of tokens at any given time.
        require(dAppCount < 2 || block.timestamp > lastDAppAllocated + 180 days, "Cooldown not finished.");
        
        // Stops a new game from being created in the next 6 months.
        lastDAppAllocated = block.timestamp;
        
        // Increments game count.
        dAppAddresses[dAppCount] = newDApp;
        dAppCount += 1;
        
        // Transfers 1 billion tokens to the new dApp.
        _transfer(address(this), newDApp, 1000000000 ether);
    }
    
    function getDApp(uint8 id) external view returns(address) {
        require(dAppCount > id, "Id out of bounds.");
        return dAppAddresses[id];
    }

    function pauseTransfers() external onlyOwner whenNotPaused {
        _pause();
    }
    
    function resumeTransfers() external onlyOwner whenPaused {
        _unpause();
    }
    
}