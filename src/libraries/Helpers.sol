//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts/token/ERC20/IERC20.sol";
import {Errors} from "./Errors.sol";
import {Lockup} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";
import {Lockup_Tranche} from "src/libraries/DataTypes.sol";
import {Lockup_Dynamic} from "src/libraries/DataTypes.sol";

library Helpers {
    /*//////////////////////////////////////////////////////////////////////////
                           Create Stream Helper
    //////////////////////////////////////////////////////////////////////////*/

    function checkCommonInputsValid(Lockup.UserInput calldata params) external view {
        if (params.sender == address(0)) {
            revert Errors.LockupFactory__ZeroAddressSender();
        }

        if (params.token.balanceOf(params.sender) < params.totalAmount) {
            revert Errors.LockupFactory__InsufficientTokenBalance();
        }

        if (params.recipient == address(0)) {
            revert Errors.LockupFactory__ZeroAddressRecipient();
        }

        if (bytes(params.shape).length > 32) {
            revert Errors.LockupFactory__ShapeExceeds32Bytes(bytes(params.shape));
        }

        if (params.totalAmount == 0) {
            revert Errors.LockupFactory__TotalAmountCannotBeZero();
        }
    }

    function checkLinearLockupIsValid(
        Lockup.UserInputWithTimestamps calldata params,
        Lockup_Linear.UnlockAmounts calldata unlockAmounts,
        uint40 cliffTime
    ) external pure {
        if (!(params.timestamps.start < params.timestamps.end)) {
            revert Errors.LockupFactory__StartTimeExceedsThanEndTime();
        }

        if (!(params.timestamps.start < cliffTime)) {
            revert Errors.LockupFactory__StartTimeExceedsThanCliffTime();
        }

        if (!(cliffTime < params.timestamps.end)) {
            revert Errors.LockupFactory__CliffTimeExceedsThanEndTime();
        }

        if (cliffTime > 0) {
            if (unlockAmounts.start + unlockAmounts.cliff > params.totalAmount) {
                revert Errors.LockupFactory__TotalAmountLessThanUnlockAmounts();
            }
        } else if (unlockAmounts.cliff > 0) {
            revert Errors.LockupFactory__CliffDurationZeroButCliffUnlockAmountGreaterThanZero();
        }
    }

    function checkTrancheLockupIsValid(
        Lockup.UserInputWithTimestamps calldata params,
        Lockup_Tranche.TrancheWithTimestamps[] memory tranches
    ) external pure {
        if (params.timestamps.start >= params.timestamps.end) {
            revert Errors.LockupFactory__StartTimeExceedsThanEndTime();
        }

        if (params.timestamps.start >= tranches[0].timestamp) {
            revert Errors.LockupFactory__StartTimeExceedsFirstTranche();
        }

        if (tranches[tranches.length - 1].timestamp > params.timestamps.end) {
            revert Errors.LockupFactory__LastTrancheTimestampExceedsEndTime();
        }

        if (tranches.length == 0) {
            revert Errors.LockupFactory__TrancheCountEqualsZero();
        }

        uint40 previousTimestamp;
        uint40 currentTimestamp;
        uint256 totalAmount;

        previousTimestamp = params.timestamps.start;

        for (uint256 i = 0; i < tranches.length; i++) {
            currentTimestamp = tranches[i].timestamp;
            if (currentTimestamp <= previousTimestamp) {
                revert Errors.LockupFactory__InvalidTimestamps(i, previousTimestamp, currentTimestamp);
            }
            previousTimestamp = currentTimestamp;
            if (tranches[i].amount == 0) {
                revert Errors.LockupFactory__TrancheAmountEqualsZero(i);
            }
            totalAmount += tranches[i].amount;
        }

        if (totalAmount != params.totalAmount) {
            revert Errors.LockupFactory__TotalAmountNotEqualToTrancheUnlocks();
        }
    }

    function calculateTranchesWithTimestamps(Lockup_Tranche.TrancheWithDuration[] calldata tranches, uint40 startTime)
        external
        pure
        returns (Lockup_Tranche.TrancheWithTimestamps[] memory tranches_timestamps)
    {
        uint256 totalTrancheCount = tranches.length;

        unchecked {
            tranches_timestamps[0] = Lockup_Tranche.TrancheWithTimestamps({
                amount: tranches[0].amount,
                timestamp: tranches[0].duration + startTime
            });
        }

        for (uint256 i = 1; i < totalTrancheCount; i++) {
            tranches_timestamps[i] = Lockup_Tranche.TrancheWithTimestamps({
                amount: tranches[i].amount,
                timestamp: tranches[i].duration + tranches_timestamps[i - 1].timestamp
            });
        }
    }

    function checkDynamicLockupIsValid(
        Lockup.UserInputWithTimestamps calldata params,
        Lockup_Dynamic.SegmentsWithTimestamps[] memory segments
    ) external pure {
        if (params.timestamps.start >= params.timestamps.end) {
            revert Errors.LockupFactory__StartTimeExceedsThanEndTime();
        }

        if (params.timestamps.start >= segments[0].timestamp) {
            revert Errors.LockupFactory__StartTimeExceedsFirstSegment();
        }

        if (segments[segments.length - 1].timestamp > params.timestamps.end) {
            revert Errors.LockupFactory__LastSegmentTimestampExceedsEndTime();
        }

        if (segments.length == 0) {
            revert Errors.LockupFactory__SegmentsCountEqualsZero();
        }

        uint40 previousTimestamp;
        uint40 currentTimestamp;
        uint256 totalAmount;

        previousTimestamp = params.timestamps.start;

        for (uint256 i = 0; i < segments.length; i++) {
            currentTimestamp = segments[i].timestamp;
            if (currentTimestamp <= previousTimestamp) {
                revert Errors.LockupFactory__InvalidTimestamps(i, previousTimestamp, currentTimestamp);
            }
            previousTimestamp = currentTimestamp;
            if (segments[i].amount == 0) {
                revert Errors.LockupFactory__SegmentAmountEqualsZero(i);
            }
            totalAmount += segments[i].amount;
        }

        if (totalAmount != params.totalAmount) {
            revert Errors.LockupFactory__TotalAmountNotEqualToSegmentUnlocks();
        }
    }

    function calculateSegmentsWithTimestamps(Lockup_Dynamic.SegmentsWithDurations[] calldata segments, uint40 startTime)
        external
        pure
        returns (Lockup_Dynamic.SegmentsWithTimestamps[] memory segments_timestamps)
    {
        uint256 totalSegmentCount = segments.length;

        unchecked {
            segments_timestamps[0] = Lockup_Dynamic.SegmentsWithTimestamps({
                amount: segments[0].amount,
                timestamp: segments[0].duration + startTime,
                exponent: segments[0].exponent
            });
        }

        for (uint256 i = 1; i < totalSegmentCount; i++) {
            segments_timestamps[i] = Lockup_Dynamic.SegmentsWithTimestamps({
                amount: segments[i].amount,
                timestamp: segments[i].duration + segments_timestamps[i - 1].timestamp,
                exponent: segments[i].exponent
            });
        }
    }
}
