// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** 
 * @title TimeLock
 * @dev Implements delay on withdrawals
 */

contract TimeLock {
    struct PendingTransaction {
        address _from;
        address _to;
        uint256 amount;
        uint256 executionTime;
        bool alert;
    }

    PendingTransaction[] public pendingTransactions;

    mapping(address => uint256) public withdrawals;
    mapping(address => uint256) public accountCreation;

    address root = 0x2b3Dd70311A24A7001c8fFaC162c55994789d409;
    address tokenAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;

    // Trust Score
    // Difference between deposits and withdrawal (20% > 0.5), (50 > 0.3), (100% > 0)
    // From us - withdrawals, from defi - deposits
    function withdraw (address _defi, address _from, address _to, uint256 _amount, uint256 account_deposits) public {
        IERC20(tokenAddress).transferFrom(_defi, address(this), _amount);

        uint64 trustScore = getTrustScore(_from, _amount, account_deposits);

        applyDelay(trustScore, _from, _to, _amount);
    }

    function getTrustScore(address _user, uint256 _amount, uint256 deposits) internal view returns (uint64) {
        uint64 score = 100;

        // Check difference between deposits and withdrawals
        uint256 difference = deposits - withdrawals[_user];
        if (difference < deposits / 2) {
            score -= 10;
        } else if (difference < deposits / 5) {
            score -= 20;
        } else if (difference > 0) {
            score -= 30;
        }

        // Check the amount
        if (_amount > 200 ether) {
            score -= 30;
        } else if (_amount > 100 ether) {
            score -= 20;
        } else if (_amount > 10 ether) {
            score -= 10;
        }

        // Add off-chain

        return score;
    }

    function applyDelay(uint64 trustScore, address _from, address _to, uint256 _amount) internal returns (uint256) {
        uint256 delay = (100 - trustScore) * 24 hours / 100;

        bool alert = trustScore < 50;

        // Add the transaction to the pending list
        pendingTransactions.push(PendingTransaction({
            _from: _from,
            _to: _to,
            alert: alert,
            amount: _amount,
            executionTime: block.timestamp + delay
        }));

        return delay;
    }

     // Execute the transaction
    function executeTransaction(uint256 _index) public {
        PendingTransaction storage pt = pendingTransactions[_index];

        // Check if the execution time has passed
        if (root != msg.sender) {
            require(block.timestamp >= pt.executionTime, "Transaction delay period has not passed yet");
        }

        // Execute the transaction
        // (Assuming this is an ERC20 token)
        IERC20(tokenAddress).transfer(pt._to, pt.amount);

        // Update withdrawal amount for user
        withdrawals[pt._from] += pt.amount;

        // Remove transaction from the pending list
        delete pendingTransactions[_index];
    }
}