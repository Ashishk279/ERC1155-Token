// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


interface ERC1155TokenReceiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
contract MyERC1155Token {
    string  private name;
    string  private symbol;

    event transferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _tokenId, uint256 _value );
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _tokenIds, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _tokenId);

    mapping(address => mapping(uint256 => uint256)) public _balanceOf;
    mapping (address => mapping(address => bool)) public _isApprovedForAll;

    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _tokenIds) external view returns(uint256[] memory balances) {
        require(_owners.length == _tokenIds.length, "owners length != _tokenIds length");
        balances = new uint[](_owners.length);

        unchecked {
            for(uint256 i = 0; i < _owners.length; i++){
                balances[i] = _balanceOf[_owners[i]][_tokenIds[i]];

            }
        }
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }  

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _value, bytes calldata data) external {
        require(msg.sender == _from || _isApprovedForAll[_from][msg.sender], "not approved");
        require(_to != address(0), "_to = 0 address");

        _balanceOf[_from][_tokenId] -= _value;
        _balanceOf[_to][_tokenId] += _value;

        emit transferSingle(msg.sender, _from, _to, _tokenId, _value);
        if(_to.code.length > 0) {
            require(ERC1155TokenReceiver(_to).onERC1155Received(msg.sender, _from, _tokenId, _value, data)
             == ERC1155TokenReceiver.onERC1155Received.selector,"unsafe transfer");
        }
    }

    function safeBatchTransferFrom(
        address _from, address _to, 
        uint256[] memory _tokenIds, 
        uint256[] memory _values, 
        bytes calldata data
        ) 
        external {
            require(msg.sender == _from || _isApprovedForAll[_from][msg.sender], "not approved");
            require(_to != address(0), "_to = 0 address");
            require(_tokenIds.length == _values.length, "_tokenIds length != _values length");

            for(uint256 i = 0; i < _tokenIds.length; i++){
                _balanceOf[_from][_tokenIds[i]] -= _values[i];
                _balanceOf[_to][_tokenIds[i]] += _values[i]; 
            }

            emit TransferBatch(msg.sender, _from, _to, _tokenIds, _values);
            if(_to.code.length > 0) {
                require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender, _from, _tokenIds, _values, data) 
                == ERC1155TokenReceiver.onERC1155BatchReceived.selector, "unsafe transfer");
            }

    }

    function supportsInterface(bytes4 _interfaceId) external pure returns(bool) {
        return _interfaceId == 0x01ffc9a7 || _interfaceId == 0xd9b67a26 || _interfaceId == 0x0e89341c;
            
       
    }

    function _mint(address _to, uint256 _tokenId, uint256 _value, bytes memory data) external {
        require(_to != address(0), "to = 0 address");
        _balanceOf[_to][_tokenId] += _value;
        emit transferSingle(msg.sender, address(0), _to, _tokenId, _value);
        if(_to.code.length > 0) {
            require(ERC1155TokenReceiver(_to).onERC1155Received(msg.sender,address(0), _tokenId, _value, data)
            == ERC1155TokenReceiver.onERC1155Received.selector,"unsafe transfer");
        }
    }
    function _Batchmint(address _to, uint256[] calldata _tokenIds, uint256[] calldata _values, bytes memory data) external {
        require(_to != address(0), "to = 0 address");

        for(uint i = 0; i < _tokenIds.length; i++){
            _balanceOf[_to][_tokenIds[i]] += _values[i];
        }
        emit TransferBatch(msg.sender, address(0), _to, _tokenIds, _values);
        if(_to.code.length > 0) {
            require(ERC1155TokenReceiver(_to).onERC1155BatchReceived(msg.sender,address(0), _tokenIds, _values, data)
            == ERC1155TokenReceiver.onERC1155BatchReceived.selector,"unsafe transfer");
        }
    }

    function _burn(address _from, uint256 _tokenId, uint256 _value) external {
        require(_from != address(0), "_from = 0 address");
        _balanceOf[_from][_tokenId] -= _value;
        emit transferSingle(msg.sender, _from, address(0), _tokenId, _value);
    }

    function _batchBurn(address _from, uint256[] calldata _tokenIds, uint256[] calldata _values) external {
        require(_from != address(0), "_from = 0 address");

        for(uint i = 0; i < _tokenIds.length; i++){
           _balanceOf[_from][_tokenIds[i]] -= _values[i];
        }
        emit TransferBatch(msg.sender, _from, address(0), _tokenIds, _values);
    }
     
    constructor (string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
    }

    function Name() external view returns( string memory ){
        return name;
    }
    function Symbol() external view returns(string memory ){
        return symbol;
    }

    

}