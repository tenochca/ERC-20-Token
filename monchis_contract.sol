//DS mintAsOwner should be public
//DS: whenNotPaused has incorrect require logic. 

// SPDX-License-Identifier: MIT

//Specify the required compiler to use.
pragma solidity >=0.7.0 <0.9.0; 

// ERC-20 interface as defined https://eips.ethereum.org/EIPS/eip-20
interface IERC20 {
    // Returns the value of tokens in existence.
    function totalSupply() external view returns (uint256);
    
    // Returns the value of tokens owned by account.
    function balanceOf(address account) external view returns (uint256);
    
    //Moves a value amount of tokens from the caller’s account to to.
    //Returns a boolean value indicating whether the operation succeeded.
    //Emits a transfer event.
    function transfer(address to, uint256 value) external returns (bool);
    
    //Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom. This is zero by default.
    //This value changes when approve or transferFrom are called.
    function allowance(address owner, address spender) external view returns (uint256);
    
    //Sets a value amount of tokens as the allowance of spender over the caller’s tokens.
    //Returns a boolean value indicating whether the operation succeeded.
    //Emits an Approval event.
    function approve(address spender, uint256 value) external returns (bool);

    //Moves a value amount of tokens from from to to using the allowance mechanism. value is then deducted from the caller’s allowance.
    //Returns a boolean value indicating whether the operation succeeded.
    //Emits a transfer event.
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    //Emitted when value tokens are moved from one account (from) to another (to).
    //Note that value may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    //Emitted when the allowance of a spender for an owner is set by a call to approve. value is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DemonToken is IERC20 {
    string public name = "Monchis";
    string public symbol = "MCI";
    uint8 public decimals = 18;

    uint private _totalSupply;
    uint public cappedSupply;
    address private _owner;
    bool private _paused;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint _cappedSupply, uint _initialMint) {
        _owner = msg.sender;
        cappedSupply = _cappedSupply * (10 ** decimals);
        _balances[msg.sender] = _initialMint;
        _totalSupply = _initialMint;
        mintAsOwner(msg.sender, _initialMint * (10 ** decimals));
        emit Transfer(address(0), msg.sender, _initialMint);
    }

    function getOwner() public view returns (address) {
        return _owner;
    
    }

    modifier onlyOwner { //mofier checks if the sender is the owner
        require(msg.sender == _owner, "You must be the owner");
        _;
    }

    function setOwner(address owner) public onlyOwner {
        _owner = owner;

    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }

    function flipPaused() public onlyOwner {
        if (_paused == true) {
            _paused = false;
        } 
        else if (_paused == false) {
            _paused = true;
        }
    }

    modifier whenNotPaused {
        require(_paused == false, "Contract is paused!");
        _;
    }

    function _mint(address _address, uint _amount) private whenNotPaused {
        require(_totalSupply < cappedSupply && _address != address(0));
        _totalSupply += _amount;
        _balances[_address] += _amount;
    }

    function mintAsOwner(address _address, uint _ammount) public onlyOwner whenNotPaused {
        _mint(_address, _ammount);
    }

    function burn(uint _amount) public {
        require (_balances[msg.sender] >= _amount);
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0), "Invalid address");
        
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 value) public override returns (bool) {
        require(sender != address(0), "Invalid address");
        require(recipient != address(0), "Invalid address");
        require(_balances[sender] >= value, "Insufficient balance");
        require(_allowances[sender][msg.sender] >= value, "Transfer value exceeds allowance");

        _balances[sender] -= value;
        _balances[recipient] += value;
        _allowances[sender][msg.sender] -= value;
        emit Transfer(sender, recipient, value);
        return true;
    }
}

//TODO: Please complete the following steps to finish the ERC-20 token:

// Feel free to use your code from DemonToken_Ex_1.sol as a starting point.

//      Add a private variable named _owner that is an address.
//      Update the constructor to set the state variable _owner to the address that deployed the contract.
//      Add a getter function named getOwner that returns _owner.
//      Add a modifier function onlyOwner, check that the msg.sender is the owner of the contract, if not return an error message "Must be owner!"
//      Add a function named setOwner that accepts an address argument, and updates the owner of the contract to the new address. This function should be decorated with onlyOwner.

//2. Add a modifier named whenNotPaused that will restrict access to certain functions when the contract is paused.
//      Add a private variable named _paused that is a bool.
//      Add a function named isPaused that returns the value of _paused.
//      Add a function named flipPaused that will toggle the value of _paused between true and false. This function should be decorated with onlyOwner.
//      Add a modifier function whenNotPaused, check that the contract is not paused, if it is return an error message "Contract is paused!"

//3. Add a private function named _mint that accepts an address argument and a uint argument, and mints the specified amount of tokens to the specified address.
//      the function should update both the _totalSupply and _balances state variables.
//      the function should emit a Transfer event.
//      the function should check that the address is valid, and that the capped supply has not been reached.

//4. Add a function named mintAsOwner that accepts an address argument and a uint argument, and mints the specified amount of tokens to the specified address. This function should only be callable by the owner of the contract and can run only when not paused.
//      Use the _mint function to mint the tokens.

//5. Add a function named burn that accepts a uint argument, and burns the specified amount of tokens from the caller of the function.
//      the function should check that the caller has enough tokens to burn.
//      the function should update both the _totalSupply and _balances state variables.
//      the function should emit a Transfer event. hint: addres(0) should be used.

//6. Compile and test your contract. upload the .sol file to the D2L submission page.