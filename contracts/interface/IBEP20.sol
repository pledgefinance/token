pragma solidity 0.4.24;

contract BEP20Interface {

    function symbol()
        public
        view
        returns (string memory);

    function name()
        public
        view
        returns (string memory);

    function decimals()
        public
        view
        returns (uint8);

    function totalSupply()
        public
        view
        returns (uint256);

    function balanceOf(
        address _address)
        public
        view
        returns (uint256 balance);

    function allowance(
        address _address,
        address _to)
        public
        view
        returns (uint256 remaining);

    function transfer(
        address _to,
        uint256 _value)
        public
        returns (bool success);

    function approve(
        address _to,
        uint256 _value)
        public
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool success);

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}