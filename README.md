# TimeLock

## Overview

TimeLock is an Ethereum smart contract developed to secure and protect the interests of users by implementing a time delay on withdrawals. The delay varies based on a dynamic trust score system, which evaluates the user's past transaction history and patterns to create a trust score. 

The system is designed to add an additional layer of security for users by deterring malicious actors and reducing the risk of fund loss through attacks or system exploitation.

## Contract Features

- **Trust Score System:** Calculates a trust score based on user's past transactions history, including their transaction frequency and amount.
- **Dynamic Withdrawal Delay:** Applies a delay on withdrawals based on the user's trust score. The lower the trust score, the longer the delay.
- **Alerts:** Notifies when a transaction is considered risky, i.e., when the trust score falls below a certain threshold.
- **Execution Control:** Transactions can be manually executed once the delay period has passed.

## Implementation Details

The contract holds the details of all pending transactions in the `pendingTransactions` array. Each pending transaction stores the following details:
- Sender of the transaction
- Recipient of the transaction
- Amount to be transferred
- Time when the transaction can be executed
- Alert status indicating if the transaction is considered risky

The `withdraw` function is the main function to initiate a withdrawal. It calculates the trust score of the user, applies the delay based on the score, and adds the transaction details to the `pendingTransactions` array.

The `getTrustScore` function calculates the trust score of a user based on the following parameters:
- Difference between deposits and withdrawals
- Amount to be withdrawn
- (Add off-chain parameters)

The `applyDelay` function applies a delay to the transaction based on the trust score calculated. The lower the trust score, the longer the delay applied.

The `executeTransaction` function executes the transaction only if the delay period has passed.

## Contract Interactions

1. Initiate a withdrawal by calling the `withdraw` function with the necessary parameters.
2. The contract will calculate the trust score, apply a delay, and add the transaction to the `pendingTransactions` array.
3. Once the delay period has passed, call `executeTransaction` to execute the transaction.

## Future Development

- Incorporation of off-chain parameters to enrich the trust score computation.
- Implementing an API to alert an external system or admins about risky transactions.
- Implementing a gas price based trust score system to detect price manipulation attempts.
- More detailed transaction history to improve the accuracy of the trust score system.

## Disclaimer

This smart contract has been created for a hackathon and is not audited. Please ensure thorough testing and auditing before using this in production.

## Dependencies

- "@openzeppelin/contracts/token/ERC20/IERC20.sol": For handling ERC20 token transactions.
