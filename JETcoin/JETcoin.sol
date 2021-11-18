pragma solidity ^0.5.0; //솔라디티 버전
// https://ide.klaytn.com/ -> Klaytn IDE

// ERC20 표준
interface IERC20 {
    function totalSupply() external view returns (uint256);
    // balanceOf() 주어진 주소의 잔액을 반환
    function balanceOf(address account) external view returns (uint256);
    // transfer()는 amount 만큼의 토큰을 recipient에게 전송
    // 내부에서 _transfer(msg.sender, recipient, amount) 함수를 호출
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    // spender가 amount 한도하에서 여러번 출금하는 것을 허용 
    // 내부에서 _approve(msg.sender, spender, value) 함수를 호출
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
    //BOF 등의 취약점을 막기 위한 모듈
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract JET is IERC20 { // JET 컨트렉트는 IERC20표준을 상속
    using SafeMath for uint256; 
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    // https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.3.0/contracts/token/ERC20/ERC20Detailed.sol 시작 부분을 참고
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    //생성자
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _mint(msg.sender, 100000 * 10 ** uint256(decimals)); // 주의!
    }
    //토큰의 이름 반환
    function name() public view returns (string memory) {
        return _name;
    }
    //토큰의 심볼 반환
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    //토큰의 개수관련 정보 반환 => 일반적으로 8
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    // https://github.com/OpenZeppelin/openzeppelin-solidity/blob/v2.3.0/contracts/token/ERC20/ERC20Detailed.sol 끝 부분을 참고
    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

     //amount 만큼의 코인을 생성하고(_totalSupply) 해당 코인들을 "account"에 전송 
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    //`account`로부터 `amount`만큼의 토큰을 파괴하고, 전체 공급량을 감소시킵니다.
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    // `owner`의 토큰에 대한 `spender`의 허용량을 `amount`만큼 설정합니다.
     
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // `account`로부터 `amount`만큼의 토큰을 파괴하고 호출자의 허용량으로부터 `amount`만큼을 공제합니다.

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}