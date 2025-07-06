//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

library Errors {
    /// @notice The stream creator is not allowed to spend the senders tokens
    error LockupStream__InsufficientTokenBalance();

    /// @notice The recipient is a invalid. address = 0;
    error LockupStream__ZeroAddressRecipient();

    /// @notice Total Amount is less than sum unlock amounts
    error LockupStream__TotalAmountLessThanUnlockAmounts();
}
