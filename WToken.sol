pragma solidity ^0.5.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable {
    address public owner;

    constructor () public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable.onlyOwner:not owner");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract ERC20Basic {
    uint256 public _totalSupply;
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public;
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public;
    function approve(address spender, uint256 value) public;
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;
    
    function transfer(address _to, uint256 _value) public {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
    }
    
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

}

contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint256)) public allowed;

    uint256 public constant MAX_UINT = 2**256 - 1;
    
    function transferFrom(address _from, address _to, uint256 _value) public {
        uint256 _allowance = allowed[_from][msg.sender];

        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
    }
    
    function approve(address _spender, uint256 _value) public {
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)), "StandardToken:approve:fail");

        allowed[msg.sender][_spender] = _value;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

contract Pausable is Ownable {

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused, "Pausable:paused");
    _;
  }

  modifier whenPaused() {
    require(paused, "Pausable:not paused");
    _;
  }
  
  function pause() public onlyOwner whenNotPaused  {
    paused = true;
  }
  
  function unpause() public onlyOwner whenPaused  {
    paused = false;
  }

  function getStatus() public view returns (bool){
      return paused;
  }
}

contract BlackList is BasicToken {

    mapping (address => bool) public isBlackListed;

    function getBlackListStatus(address _maker) public view returns (bool) {
        return isBlackListed[_maker];
    }
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser], "BlackList.destroyBlackFunds:is not in blacklist");
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
    }
}

contract WToken is Pausable, StandardToken, BlackList{

    string public name;
    string public symbol;

    constructor (uint256 _initialSupply, string memory _name, string memory _symbol) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        balances[owner] = _initialSupply;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256){
        return super.balanceOf(who);
    }

    function transfer(address _to, uint256 _value) public whenNotPaused {
        // Check black list
        require(!isBlackListed[msg.sender], "WToken.transfer:is in black list");

        // Check sender balance enough
        require(balances[msg.sender] >= _value, "WToken.transfer:balance not enough");
        
         // Check value > 0
        require(balances[_to].add(_value) >= balances[_to], "WToken.transfer:_value not positive");

        super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused {
        // Check black list
        require(!isBlackListed[_from], "WToken.transferFrom:is in black list");

        // Check sender balance enough
        require(balances[_from] >= _value, "WToken.transferFrom:balance not enough");
        
         // Check value > 0
        require(balances[_to].add(_value) >= balances[_to], "WToken.transferFrom:_value not positive");

        super.transferFrom(_from, _to, _value);
    }

    function getSecret() public onlyOwner view returns (uint256){
        return 12345;
    }
}