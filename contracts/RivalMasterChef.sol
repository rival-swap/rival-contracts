pragma solidity 0.6.12;

import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";

import "./libs/IBEP20.sol";
import "./RewardDistributor.sol";

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
        uint256 pendingReward; // Not harvested by some reasons
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
    RewardDistributor public minter;
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
        RewardDistributor _minter,
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
        public
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
        return
            user.pendingReward.add(
                user.amount.mul(accRivalPerShare).div(1e22).sub(user.rewardDebt)
            );
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
        UserInfo storage user = userInfo[_pid][_msgSender()];
        updatePool(_pid);
        updateUser(_pid, _msgSender());
        uint256 pendingReward = pendingRival(_pid, _msgSender());
        if (pendingReward > 0) {
            uint256 harvestedAmount = safeRivalTransfer(_msgSender(), pendingReward);
            user.pendingReward = pendingReward.sub(harvestedAmount);
        }

        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.transferFrom(
                address(_msgSender()),
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
        emit Deposited(_msgSender(), _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(
            pool.lpSupply >= _amount,
            "withdraw: not good(pool balance not enough)"
        );

        updatePool(_pid);
        updateUser(_pid, _msgSender());

        require(
            user.unlockedAmount >= _amount,
            "withdraw: not good(user unlocked balance not enough)"
        );

        uint256 pendingReward = pendingRival(_pid, _msgSender());
        if (pendingReward > 0) {
            uint256 harvestedAmount = safeRivalTransfer(_msgSender(), pendingReward);
            user.pendingReward = pendingReward.sub(harvestedAmount);
        }

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            user.unlockedAmount = user.unlockedAmount.sub(_amount);
            pool.lpSupply = pool.lpSupply.sub(_amount);
            pool.lpToken.transfer(_msgSender(), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRivalPerShare).div(1e22);
        emit Withdrawn(_msgSender(), _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        pool.lpToken.transfer(_msgSender(), user.amount);
        emit EmergencyWithdrawn(_msgSender(), _pid, user.amount);
        user.amount = 0;
        user.unlockedAmount = 0;
        for (uint256 i = user.arrLockedUntil.length - 1; i >= 0; i--) {
            user.lockedAmounts[user.arrLockedUntil[i]] = 0;
            user.arrLockedUntil.pop();
        }
        user.rewardDebt = 0;
    }

    // Safe $RIVAL transfer function, just in case if rounding error causes pool to not have enough $RIVALs.
    function safeRivalTransfer(address _to, uint256 _amount)
        internal
        returns (uint256)
    {
        return minter.safeRivalTokenTransfer(_to, _amount);
    }

    function setFeeAddress(address _feeAddress) external {
        require(_msgSender() == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit FeeAddressUpdated(_msgSender(), _feeAddress);
    }

    // Update start block number
    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        require(startBlock > block.number, "Farm already started");
        require(_startBlock > block.number, "Invalid block");
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].lastRewardBlock = _startBlock;
        }
        emit StartBlockUpdated(_msgSender(), startBlock, _startBlock);
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
        emit EmissionRateUpdated(_msgSender(), rivalPerBlock, _rivalPerBlock);
        rivalPerBlock = _rivalPerBlock;
    }
}
