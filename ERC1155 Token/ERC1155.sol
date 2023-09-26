// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyToken is ERC1155 {
    constructor(string memory name, string memory symbol) ERC1155(name){}

    function mint(address to, uint256 id, uint256 amount) public {
        _mint(to ,id,amount, "");
    }

    function burn(address from, uint256 id, uint256 amount) public {
        _burn(from, id, amount);
    }

}


