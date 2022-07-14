// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract SourceToken {
    uint private _totalSupply;

    // 18 decimals is strongly suggested because 1ether = 10^18 wei
    uint8 private _decimals = 18;
    string private _name;
    string private _symbol;


    // check the balance of the particular account
    mapping(address => uint256) public balanceOf;

    // Max amount of tokens which can be transfer by one address to another address 
    mapping(address => mapping(address => uint256)) private allowance;
    
    event Transfer(address _from, address _to, uint amount);
    event Burn(address _from, uint amount);
    event Approval(address _owner, address _to, uint amount);


    constructor(
        uint initialSupply, 
        string memory name_, 
        string memory symbol_
        ) {
        // Update total supply with the decimal amount
        _totalSupply = initialSupply * 10** uint(_decimals);
        // Give the creator all initial tokens
        balanceOf[msg.sender] = _totalSupply;
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    function totalSupply() public view returns(uint) {
        return _totalSupply;
    }

    function balanceOf_(address _owner) public view returns(uint) {
        return balanceOf[_owner];
    }



    function transfer(address from, address to, uint256 amount) internal{
        // Prevent transfer to 0x0 address. Use burn() instead 
        require(to != address(0));
        // Check if the sender has enough
        require(balanceOf[from] >= amount);
        // Check for overflows
        require(balanceOf[to] + amount >= balanceOf[to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[from] + balanceOf[to];

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        assert(balanceOf[from] + balanceOf[to] == previousBalances);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool success) {
       require(amount <= allowance[from][msg.sender]);
       allowance[from][msg.sender] -= amount;
       transfer(from, to, amount);
       return true;
    }
   
//    Set allowance for other address and notify
    function approve(address _spender, uint _value) public returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

// Destroy tokens

    function burn(uint _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    // Destroy tokens from other account

    function burnFrom(address _from, uint _value) public returns(bool success){
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[msg.sender][_from]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(_from, _value);
        return true;

    }

}