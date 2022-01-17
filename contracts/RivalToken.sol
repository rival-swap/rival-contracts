// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./libs/BEP20.sol";

// RivalToken with Governance.
contract RivalToken is BEP20 {
    using SafeMath for uint256;

    // Transfer tax rate in basis points. (default 1%)
    uint16 public transferTaxRate = 100;
    uint16 public constant MAXIMUM_TRANSFER_TAX_RATE = 1000;

    // Reserve address
    address public reserveWallet = address(0x1431b86468D384235bDBf171bA07a73061bbf8c9);

    // Addresses that excluded from transfer tax
    mapping(address => bool) private _excludedFromTax;
    
    // Events
    event TransferTaxRateUpdated(address indexed owner, uint256 previousRate, uint256 newRate);
    event AccountExcludedFromTax(address indexed account, bool excluded);
    event ReserveWalletUpdated(address indexed oldAddress, address indexed newAddress);
    event BnbRecovered(address indexed owner, uint256 balance);

    /**
     * @notice Constructs the RivalToken contract.
     */
    constructor() public BEP20("Bit Rivals", "$RIVAL") {
        _excludedFromTax[msg.sender] = true;
        _excludedFromTax[address(0)] = true;
        _excludedFromTax[address(this)] = true;
        _excludedFromTax[reserveWallet] = true;

        mint(msg.sender, 10**17);
    }

    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) internal onlyOwner {
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
    }

    /**
     * @dev Recover bnb in the token contract
     * 
     */
    function recoverBnb() external onlyOwner {
        require(address(this).balance > 0, "No balance");
        emit BnbRecovered(owner(), address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @dev overrides transfer function to meet tokenomics of RIVAL
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (_excludedFromTax[sender] || _excludedFromTax[recipient] || transferTaxRate == 0) {
            super._transfer(sender, recipient, amount);
            _moveDelegates(_delegates[sender], _delegates[recipient], amount);
        } else {
            // default tax is 1% of every transfer
            uint256 taxAmount = amount.mul(transferTaxRate).div(10000);
            // default 99% of transfer sent to recipient
            uint256 sendAmount = amount.sub(taxAmount);
            require(amount == sendAmount.add(taxAmount), "RIVAL::transfer: Tax value invalid");

            super._transfer(sender, reserveWallet, taxAmount);
            super._transfer(sender, recipient, sendAmount);
            _moveDelegates(_delegates[sender], _delegates[recipient], sendAmount);
            _moveDelegates(_delegates[sender], _delegates[reserveWallet], taxAmount);
        }
    }

    // To receive BNB
    receive() external payable {}

    /**
     * @dev Update the reserve wallet.
     * Can only be called by the current reserve address.
     */
    function updateReserveWallet(address _newWallet) external {
        require(msg.sender == reserveWallet, "RIVAL::updateReserveWallet: Invalid operation");
        require(_newWallet != address(0), "RIVAL::updateReserveWallet: Invalid new reserve wallet");
        emit ReserveWalletUpdated(reserveWallet, _newWallet);
        reserveWallet = _newWallet;
    }

    /**
     * @dev Update the transfer tax rate.
     * Can only be called by the current owner.
     */
    function updateTransferTaxRate(uint16 _transferTaxRate) public onlyOwner {
        require(_transferTaxRate <= MAXIMUM_TRANSFER_TAX_RATE, "RIVAL::updateTransferTaxRate: Transfer tax rate must not exceed the maximum rate.");
        emit TransferTaxRateUpdated(msg.sender, transferTaxRate, _transferTaxRate);
        transferTaxRate = _transferTaxRate;
    }

    /**
     * @dev Exclude or include an address from transfer tax.
     * Can only be called by the current owner.
     */
    function setExcludedFromTax(address _account, bool _excluded) public onlyOwner {
        require(_excludedFromTax[_account] != _excluded, "RIVAL::setExcludedFromTax: Already set");
        emit AccountExcludedFromTax(_account, _excluded);
        _excludedFromTax[_account] = _excluded;
    }

    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @dev A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint256 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint256) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "RIVAL::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "RIVAL::delegateBySig: invalid nonce");
        require(now <= expiry, "RIVAL::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint256 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints.sub(1)].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "RIVAL::getPriorVotes: not yet determined");

        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints.sub(1)].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints.sub(1)].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint256 lower = 0;
        uint256 upper = nCheckpoints.sub(1);
        while (upper > lower) {
            uint256 center = upper.sub(upper.sub(lower).div(2)); // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center.sub(1);
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying RIVALs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint256 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum.sub(1)].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint256 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum.sub(1)].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint256 blockNumber = block.number;

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints.sub(1)].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints.sub(1)].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints.add(1);
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}
