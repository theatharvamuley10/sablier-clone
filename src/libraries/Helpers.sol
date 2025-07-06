//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {Errors} from "./Errors.sol";
import {Lockup} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";

library Helpers {
    /// @dev Checks if the message sender has allowance to stream senders tokens.
    function _checkSenderHasBalance(
        address sender,
        uint256 totalAmount,
        IERC20 token
    ) internal view {
        if (token.balanceOf(sender) < totalAmount) {
            revert Errors.LockupStream__InsufficientTokenBalance();
        }
    }

    /// @dev Checks if the recipient is a valid account address.
    function _checkRecipientIsValid(address recipient) internal pure {
        if (recipient == address(0)) {
            revert Errors.LockupStream__ZeroAddressRecipient();
        }
    }

    /// @dev Checks for the validity of total amount and unlock amounts for Linear Lockuo
    function _checkAmountsAreValidLL(
        Lockup_Linear.UnlockAmounts memory unlockAmounts
    ) internal pure {
        if (!(unlockAmounts.total > unlockAmounts.start + unlockAmounts.cliff))
            revert Errors.LockupStream__TotalAmountLessThanUnlockAmounts();
    }

    /// @dev Check validity of Linear Lockup stream
    function checkLinearLockupIsValid(
        Lockup_Linear.StreamLL memory streamLL
    ) external view returns (bool) {
        _checkSenderHasBalance(
            streamLL.sender,
            streamLL.unlockAmounts.total,
            streamLL.token
        );
        _checkRecipientIsValid(streamLL.recipient);
        _checkAmountsAreValidLL(streamLL.unlockAmounts);
        return true;
    }
}
