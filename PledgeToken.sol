pragma solidity ^0.8.1;

contract BEP20Interface {

  function symbol() public view returns (string);

  function name() public view returns (string);

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
    TransferOwnership(msg.sender, _newOwner)
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
    Paused();
  }

  function unpause() onlyOwner whenPaused public {
    pause = false;
    Unpaused();
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

  string public symbol;
  string public name;
  uint8 public decimals;
  uint256 public totalSupply;

  const uint256 MAX_TOTAL_SUPPLY = 3_000_000_000_000_000_000_000_000_000;

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowances;

  constructor() {
    symbol = "PLGR";
    name = "Pledger";
    decimals = 18;
    totalSupply = 0;
  }

  function symbol() public view returns string {
    return symbol;
  }

  function name() public view returns string {
    return name;
  }

  function decimals() public view returns uint8 {
    return decimals;
  }

  function totalSupply() public view returns uint256 {
    return totalSupply
  }

  function balanceOf(address _account) public view returns uint256 {
    require(_account != 0x0);
    return balances[_account];
  }

  function transfer(address _to, uint256 _value) public whenUnpaused returns (bool success) {
    return _transfer(msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenUnpaused returns (bool success) {
    require(allowances[_from][msg.sender] >= value, "Insufficient allowance");
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);

    return _transfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenUnpaused returns (bool success) {
    require(_spender != 0x0);
    allowances[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);
    return True;
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

    Transfer(_from, _to, _value);
    return True;
  }

  function _mint(uint256 _amount) public returns (bool success) {
    uint256 newSupply = _totalSupply.add(amount);
    require(MAX_TOTAL_SUPPLY >= newSupply, "Mint amount exceeds total supply cap");

    totalSupply = newSupply;
    balances[msg.sender] = balances[msg.sender].add(amount);

    Transfer(address(0), msg.sender, amount);
    return true;
  }

  function _burn(uint256 _amount) public returns (bool success) {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    totalSupply = totalSuppy.sub(amount);

    Transfer(msg.sender, address(0), amount);
    return true;
  }
}
