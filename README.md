# Hexareign Truffle Project
This project contains the solidity code used to make the [hexareign game](https://hexareign.com/). Feel free to open an issue if one is found.  

### Dependencies
You will need Truffle, Ganache, and NPM to work with this project.  

### Directions
Follow the directions to get a proper directory:  

First, we need to install our zeppelin dependencies: `npm install`.  

You can compile with `truffle compile`.

Order of operations:  
1. Publish HEXRToken & TileNFT.
2. Publish HEXRGameData using the HEXRToken & TileNFT addresses.
3. Publish HEXRGameLogicV1 using the HEXRGameData address.
4. Publish all of the Improvements & add them to HEXRGameData.

User's order of operations:
1. Opt into the HEXRToken contract.
2. Opt into the HEXRGameLogicV1 contract.
3. Opt into the TileNFT contract.

We still need some way of ensuring that every tile gets correctly initialzied. 
I figure that we're just going to initialize it during auctions and go from there.
