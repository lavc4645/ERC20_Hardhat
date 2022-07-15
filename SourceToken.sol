// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface tokenRecipient {
  function receiveApproval(
    address _from,
    uint256 _value,
    address _token,
    bytes calldata _extraData
  ) external;
}

contract SourceToken {
    uint private _totalSupply;

    // 18 decimals is strongly suggested because 1ether = 10^18 wei
    uint8 private _decimals = 18;
    string private _name;
    string private _symbol;


    // check the balance of the particular account
    mapping(address => uint256) private balanceOf;

    // Max amount of tokens which can be transfer by one address to another address 
    mapping(address => mapping(address => uint256)) public allowance;
    
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
        // allowance[msg.sender][msg.sender] = _totalSupply;
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


    function _transfer(address from, address to, uint256 amount) internal{
        // Prevent transfer to 0x0 address. Use burn() instead 
        require(to != address(0), " Zero Address");
        // Check if the sender has enough
        require(balanceOf[from] >= amount, "Not enough amount in sender's wallet");
        // Check for overflows
        require(balanceOf[to] + amount >= balanceOf[to], "Buffer overflow");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[from] + balanceOf[to];

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        assert(balanceOf[from] + balanceOf[to] == previousBalances);
    }


    /**
    * Transfer tokens
    *
    * Calls the internal transfer function 
    *
    * transfer from your account
    */
    function transfer(address to, uint256 _value) public returns (bool success){
        _transfer(msg.sender, to, _value);
        return true;
    }


    /**
    * Transfer tokens
    *
    * Calls the internal transfer function 
    *
    * transfer from sender to recipent
    */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool success) {
       require(amount <= allowance[from][msg.sender], "Not allowed");
       allowance[from][msg.sender] -= amount;
       _transfer(from, to, amount);
       return true;
    }
   

   /**
   * Set allowance for other address
   *
   * Allows `_spender` to spend no more than `_value` tokens on your behalf
   *
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   */
//    Set allowance for other address and notify
    function approve(address _spender, uint _value) public returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
   * Set allowance for other address and notify
   *
   * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
   *
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   * @param _extraData some extra information to send to the approved contract
   */
   function approveAndCall(
       address _spender,
       uint256 _value,
       bytes memory _extraData
   ) public returns (bool success) {
       tokenRecipient spender = tokenRecipient(_spender);
       if (approve(_spender, _value)) {
           spender.receiveApproval(msg.sender, _value, address(this), _extraData);
           return true;
       }
   }

// Destroy tokens

    function burn(uint _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Sorry");
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