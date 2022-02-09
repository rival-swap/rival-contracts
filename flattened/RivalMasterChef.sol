// File: @pancakeswap\pancake-swap-lib\contracts\math\SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: node_modules\@pancakeswap\pancake-swap-lib\contracts\GSN\Context.sol



pragma solidity >=0.4.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @pancakeswap\pancake-swap-lib\contracts\access\Ownable.sol



pragma solidity >=0.4.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\libs\IBEP20.sol



pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: node_modules\@openzeppelin\contracts\utils\Context.sol



pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin\contracts\utils\ReentrancyGuard.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts\RivalMinter.sol

pragma solidity 0.6.12;




// Rival Minter with $RIVAL in the contracts.
contract RivalMinter is Ownable, ReentrancyGuard {
    // The $RIVAL TOKEN!
    IBEP20 public rivalToken;

    // The operator can only withdraw wrong tokens in the contract
    address private _operator;

    // Event
    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );
    event OperatorTokenRecovery(address tokenRecovered, uint256 amount);

    modifier onlyOperator() {
        require(
            _operator == msg.sender,
            "operator: caller is not the operator"
        );
        _;
    }

    constructor(IBEP20 _rivalToken) public {
        rivalToken = _rivalToken;
        _operator = _msgSender();

        emit OperatorTransferred(address(0), _operator);
    }

    // Safe $RIVAL transfer function, just in case if rounding error causes pool to not have enough $RIVALs.
    function safeRivalTokenTransfer(address _to, uint256 _amount)
        public
        onlyOperator
        nonReentrant
    {
        uint256 rivalBal = rivalToken.balanceOf(address(this));
        if (_amount > rivalBal) {
            _amount = rivalBal;
        }
        if (_amount > 0) {
            rivalToken.transfer(_to, _amount);
        }
    }

    /**
     * @dev operator of the contract
     */
    function operator() public view returns (address) {
        return _operator;
    }

    /**
     * @dev Transfers operator of the contract to a new account (`newOperator`).
     * Can only be called by the current operator.
     */
    function transferOperator(address newOperator) external onlyOwner {
        require(
            newOperator != address(0),
            "RivalMinter::transferOperator: new operator is the zero address"
        );
        emit OperatorTransferred(_operator, newOperator);
        _operator = newOperator;
    }

    /**
     * @notice It allows the operator to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @param _tokenAmount: the number of tokens to withdraw
     * @dev This function is only callable by operator.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {
        IBEP20(_tokenAddress).transfer(msg.sender, _tokenAmount);
        emit OperatorTokenRecovery(_tokenAddress, _tokenAmount);
    }
}

// File: contracts\RivalMasterChef.sol

pragma solidity 0.6.12;





// import "@nomiclabs/buidler/console.sol";

// RivalMasterChef is the master of $RIVAL. He can make $RIVAL and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once $RIVAL is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract RivalMasterChef is Ownable {
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 unlockedAmount; // Unlocked amount
        uint256[] arrLockedUntil; // Array of lock end time
        mapping(uint256 => uint256) lockedAmounts; // locked amount for the lock end time

        //
        // We do some fancy math here. Basically, any point in time, the amount of $RIVALs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRivalPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRivalPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken; // Address of LP token contract.
        uint256 lpSupply; // Pool lp supply
        uint256 allocPoint; // How many allocation points assigned to this pool. $RIVALs to distribute per block.
        uint256 lastRewardBlock; // Last block number that $RIVALs distribution occurs.
        uint256 accRivalPerShare; // Accumulated $RIVALs per share, times 1e22. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 lockPeriod; // Locking period
    }

    // The $RIVAL TOKEN!
    IBEP20 public rivalToken;
    // The $RIVAL Minter!
    RivalMinter public minter;
    // Deposit Fee address
    address public feeAddress;
    // $RIVAL tokens created per block.
    uint256 public rivalPerBlock;

    // Maximum emission rate
    uint256 public constant MAXIMUM_EMISSON_RATE = 10**16;

    // Bonus muliplier for early $RIVAL makers.
    uint256 public BONUS_MULTIPLIER = 1;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Max lock period
    uint256 public constant MAX_LOCK_PERIOD = 365 days;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // Max deposit fee per pools: 20%
    uint16 public constant MAX_DEPOSIT_FEE = 2000;
    // The block number when $RIVAL mining starts.
    uint256 public startBlock;

    event Deposited(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdrawn(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event FeeAddressUpdated(address indexed user, address indexed newAddress);
    event StartBlockUpdated(
        address indexed user,
        uint256 oldValue,
        uint256 newValue
    );
    event EmissionRateUpdated(
        address indexed user,
        uint256 oldValue,
        uint256 newValue
    );

    constructor(
        IBEP20 _rivalToken,
        RivalMinter _minter,
        address _feeAddress,
        uint256 _rivalPerBlock,
        uint256 _startBlock
    ) public {
        require(_feeAddress != address(0), "Invalid fee address");
        require(
            _rivalPerBlock <=
                MAXIMUM_EMISSON_RATE.mul(10**uint256(_rivalToken.decimals())),
            "Emission value too high"
        );

        rivalToken = _rivalToken;
        minter = _minter;
        feeAddress = _feeAddress;
        rivalPerBlock = _rivalPerBlock;
        startBlock = _startBlock;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        uint16 _depositFeeBP,
        uint256 _lockPeriod,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= MAX_DEPOSIT_FEE,
            "add: invalid deposit fee basis points"
        );
        require(_lockPeriod <= MAX_LOCK_PERIOD, "Too long lock period");
        _lpToken.balanceOf(address(this)); // Check if lptoken is the actual token contract

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                lpSupply: 0,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRivalPerShare: 0,
                depositFeeBP: _depositFeeBP,
                lockPeriod: _lockPeriod
            })
        );
    }

    // Update the given pool's $RIVAL allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        uint256 _lockPeriod,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP < MAX_DEPOSIT_FEE,
            "set: invalid deposit fee basis points"
        );
        require(_lockPeriod <= MAX_LOCK_PERIOD, "Too long lock period");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].lockPeriod = _lockPeriod;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(
                _allocPoint
            );
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see user info
    function viewUserInfo(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 unlockedAmount
        )
    {
        UserInfo storage user = userInfo[_pid][_user];
        amount = user.amount;
        rewardDebt = user.rewardDebt;
        unlockedAmount = user.unlockedAmount;
        for (uint256 i = 0; i < user.arrLockedUntil.length; i++) {
            uint256 lockedUntil = user.arrLockedUntil[i];
            if (lockedUntil <= block.timestamp) {
                unlockedAmount = unlockedAmount.add(
                    user.lockedAmounts[lockedUntil]
                );
            } else {
                break;
            }
        }
    }

    // View function to see pending $RIVALs on frontend.
    function pendingRival(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRivalPerShare = pool.accRivalPerShare;

        if (
            block.number > pool.lastRewardBlock &&
            pool.lpSupply != 0 &&
            totalAllocPoint > 0
        ) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 rivalReward = multiplier
                .mul(rivalPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint);
            accRivalPerShare = accRivalPerShare.add(
                rivalReward.mul(1e22).div(pool.lpSupply)
            );
        }
        return user.amount.mul(accRivalPerShare).div(1e22).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.lpSupply == 0 || totalAllocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 rivalReward = multiplier
            .mul(rivalPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint);

        pool.accRivalPerShare = pool.accRivalPerShare.add(
            rivalReward.mul(1e22).div(pool.lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Update user with locked information
    function updateUser(uint256 _pid, address _user) internal {
        UserInfo storage user = userInfo[_pid][_user];
        uint256 needUnlockLength = 0;
        for (uint256 i = 0; i < user.arrLockedUntil.length; i++) {
            uint256 lockedUntil = user.arrLockedUntil[i];
            if (lockedUntil <= block.timestamp) {
                user.unlockedAmount = user.unlockedAmount.add(
                    user.lockedAmounts[lockedUntil]
                );
                user.lockedAmounts[lockedUntil] = 0;
            } else {
                needUnlockLength = i;
                break;
            }
        }
        if (needUnlockLength == 0) {
            return;
        }
        // Shift array to left, as needUnlockLength elements
        for (
            uint256 i = needUnlockLength;
            i < user.arrLockedUntil.length;
            i++
        ) {
            user.arrLockedUntil[i - needUnlockLength] = user.arrLockedUntil[i];
        }
        // Remove last unLockLength elements
        for (uint256 i = 0; i < needUnlockLength; i++) {
            user.arrLockedUntil.pop();
        }
    }

    // Deposit LP tokens to MasterChef for $RIVAL allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        updateUser(_pid, msg.sender);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accRivalPerShare)
                .div(1e22)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeRivalTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.transferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            _amount = pool.lpToken.balanceOf(address(this)).sub(balanceBefore);
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                if (depositFee > 0) {
                    pool.lpToken.transfer(feeAddress, depositFee);
                    _amount = _amount.sub(depositFee);
                }
            }
            user.amount = user.amount.add(_amount);
            if (pool.lockPeriod == 0) {
                user.unlockedAmount = user.unlockedAmount.add(_amount);
            } else {
                uint256 lockUntil = block.timestamp.add(pool.lockPeriod);
                user.arrLockedUntil.push(lockUntil);
                user.lockedAmounts[lockUntil] = _amount;
            }
            pool.lpSupply = pool.lpSupply.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRivalPerShare).div(1e22);
        emit Deposited(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(
            pool.lpSupply >= _amount,
            "withdraw: not good(pool balance not enough)"
        );

        updatePool(_pid);
        updateUser(_pid, msg.sender);

        require(
            user.unlockedAmount >= _amount,
            "withdraw: not good(user unlocked balance not enough)"
        );

        uint256 pending = user.amount.mul(pool.accRivalPerShare).div(1e22).sub(
            user.rewardDebt
        );

        if (pending > 0) {
            safeRivalTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            user.unlockedAmount = user.unlockedAmount.sub(_amount);
            pool.lpSupply = pool.lpSupply.sub(_amount);
            pool.lpToken.transfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRivalPerShare).div(1e22);
        emit Withdrawn(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        pool.lpToken.transfer(address(msg.sender), user.amount);
        emit EmergencyWithdrawn(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.unlockedAmount = 0;
        for (uint256 i = user.arrLockedUntil.length - 1; i >= 0; i--) {
            user.lockedAmounts[user.arrLockedUntil[i]] = 0;
            user.arrLockedUntil.pop();
        }
        user.rewardDebt = 0;
    }

    // Safe $RIVAL transfer function, just in case if rounding error causes pool to not have enough $RIVALs.
    function safeRivalTransfer(address _to, uint256 _amount) internal {
        minter.safeRivalTokenTransfer(_to, _amount);
    }

    function setFeeAddress(address _feeAddress) external {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit FeeAddressUpdated(msg.sender, _feeAddress);
    }

    // Update start block number
    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        require(startBlock > block.number, "Farm already started");
        require(_startBlock > block.number, "Invalid block");
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].lastRewardBlock = _startBlock;
        }
        emit StartBlockUpdated(msg.sender, startBlock, _startBlock);
        startBlock = _startBlock;
    }

    // Update emission rate
    function updateEmissionRate(uint256 _rivalPerBlock) external onlyOwner {
        require(
            _rivalPerBlock <=
                MAXIMUM_EMISSON_RATE.mul(10**uint256(rivalToken.decimals())),
            "Emission value too high"
        );
        massUpdatePools();
        emit EmissionRateUpdated(msg.sender, rivalPerBlock, _rivalPerBlock);
        rivalPerBlock = _rivalPerBlock;
    }
}
