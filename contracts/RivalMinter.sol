pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./libs/IBEP20.sol";

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
