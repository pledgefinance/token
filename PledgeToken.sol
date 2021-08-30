pragma solidity ^0.4.24;

contract BEP20Interface {

  function symbol() public view returns (string memory);

  function name() public view returns (string memory);

  function decimals() public view returns (uint8);

  function totalSupply() public view returns (uint256);

  function balanceOf(address _account) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool success);

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  function approve(address _spender, uint256 _value) public returns (bool success);

  function allowance(address _owner, address _spender) public view returns (uint256);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  
}

contract Ownable {
  address owner;
  uint32 transferCount;

  event TransferOwnership(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
    transferCount = 0;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    owner = _newOwner;
    transferCount = transferCount + 1;
    emit TransferOwnership(msg.sender, _newOwner);
  }

  function getOwner() public view returns (address) {
    return owner;
  }
}

contract Pausable is Ownable{
  event Paused();
  event Unpaused();

  bool public paused = false;

  modifier whenPaused() {
    require(paused);
    _;
  }

  modifier whenUnpaused() {
    require(!paused);
    _;
  }

  function pause() onlyOwner whenUnpaused public {
    paused = true;
    emit Paused();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpaused();
  }
}

library SafeMath {
    function add(
        uint256 a,
        uint256 b)
        internal
        pure
        returns(uint256 c)
    {
        c = a + b;
        require(c >= a);
    }

    function sub(
        uint256 a,
        uint256 b)
        internal
        pure
        returns(uint256 c)
    {
        require(b <= a);
        c = a - b;
    }

    function mul(
        uint256 a,
        uint256 b)
        internal
        pure
        returns(uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(
        uint256 a,
        uint256 b)
        internal
        pure
        returns(uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract PledgeToken is BEP20Interface, Ownable, Pausable {
  using SafeMath for uint256;

  string public _symbol;
  string public _name;
  uint8 public _decimals;
  uint256 public _totalSupply;

  uint256 private MAX_TOTAL_SUPPLY = 3000000000000000000000000000;

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;

  constructor() public {
    _symbol = "PLGR";
    _name = "Pledger";
    _decimals = 18;
    _totalSupply = 0;
  }

  function symbol() public view returns (string memory) {
    return _symbol;
  }

  function name() public view returns (string memory) {
    return _name;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address _account) public view returns (uint256) {
    require(_account != 0x0);
    return balances[_account];
  }

  function transfer(address _to, uint256 _value) public whenUnpaused returns (bool success) {
    return _transfer(msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenUnpaused returns (bool success) {
    require(allowances[_from][msg.sender] >= _value, "Insufficient allowance");
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);

    return _transfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenUnpaused returns (bool success) {
    require(_spender != 0x0);
    allowances[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    require(_owner != 0x0);
    require(_spender != 0x0);
    return allowances[_owner][_spender];
  }

  function mint(uint256 _amount) public onlyOwner returns (bool success) {
    return _mint(_amount);
  }

  function burn(uint256 _amount) public onlyOwner returns (bool success) {
    return _burn(_amount);
  }

  function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
    require(_to != 0x0);
    require(balances[_from] >= _value, "Insufficient balance");

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  function _mint(uint256 _amount) public returns (bool success) {
    uint256 newSupply = _totalSupply.add(_amount);
    require(MAX_TOTAL_SUPPLY >= newSupply, "Mint amount exceeds total supply cap");

    _totalSupply = newSupply;
    balances[msg.sender] = balances[msg.sender].add(_amount);

    emit Transfer(address(0), msg.sender, _amount);
    return true;
  }

  function _burn(uint256 _amount) public returns (bool success) {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    _totalSupply = _totalSupply.sub(_amount);

    emit Transfer(msg.sender, address(0), _amount);
    return true;
  }
}
