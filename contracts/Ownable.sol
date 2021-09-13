pragma solidity ^0.4.24;

contract Ownable {
    address owner;
    address newOwner;
    uint32 transferCount;

    event TransferInitiated(
        address indexed _from,
        address indexed _to
    );

    event TransferOwnership(
        address indexed _from,
        address indexed _to
    );

    constructor() public {
        owner = msg.sender;
        transferCount = 0;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(
        address _newOwner)
        public
        onlyOwner
    {
        newOwner = _newOwner;
        emit TransferInitiated(
            msg.sender,
            newOwner
        );
    }

    function getOwner()
        public
        view
        returns (address)
    {
        return owner;
    }

    function viewTransferCount()
        public
        view
        onlyOwner
        returns (uint32)
    {
        return transferCount;
    }

    function isTransferPending()
        public
        view
        returns (bool) {
        require(
            msg.sender == owner ||
            msg.sender == newOwner);
        return newOwner != address(0);
    }

    function acceptOwnership()
         public
    {
        require(msg.sender == newOwner);

        owner = newOwner;
        newOwner = address(0);
        transferCount++;

        emit TransferOwnership(
            owner,
            newOwner
        );
    }
}