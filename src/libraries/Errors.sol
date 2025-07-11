//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

library Errors {
    /// @notice Thrown when the stream creator does not have sufficient token balance to create the lockup
    error LockupFactory__InsufficientTokenBalance();

    /// @notice Thrown when the senders address is a invalid. address = 0;
    error LockupFactory__ZeroAddressSender();

    /// @notice Thrown when the recipient is a invalid. address = 0;
    error LockupFactory__ZeroAddressRecipient();

    /// @notice Thrown when the total Amount is less than sum unlock amounts
    error LockupFactory__TotalAmountLessThanUnlockAmounts();

    /// @notice Thrown when the total stream amount cannot be zero
    error LockupFactory__TotalAmountCannotBeZero();

    /// @notice Thrown when the cliff duration cannot exceed total stream duration
    error LockupFactory__CliffDurationMoreThanTotalDuration();

    /// @notice Thrown when the total amount unlocked by tranche not equal to total amount by user
    error LockupFactory__TotalAmountNotEqualToTrancheUnlocks();

    error LockupFactory__TrancheAmountEqualsZero(uint256 index);

    error LockupFactory__TrancheCountEqualsZero();

    error LockupFactory__StartTimeExceedsFirstTranche();

    error LockupFactory__LastTrancheTimestampExceedsEndTime();

    /// @notice Thrown when the total sum of segment amounts not equal to total amount by user
    error LockupFactory__TotalAmountNotEqualToSegmentUnlocks();

    error LockupFactory__StartTimeExceedsFirstSegment();

    error LockupFactory__LastSegmentTimestampExceedsEndTime();

    error LockupFactory__SegmentsCountEqualsZero();

    error LockupFactory__SegmentAmountEqualsZero(uint256 index);

    /// @notice Thrown when trying to create stream with shape string exceeding 32 bytes
    error LockupFactory__ShapeExceeds32Bytes(bytes);

    error LockupFactory__StartTimeExceedsThanEndTime();

    error LockupFactory__StartTimeExceedsThanCliffTime();

    error LockupFactory__CliffTimeExceedsThanEndTime();

    error LockupFactory__CliffDurationZeroButCliffUnlockAmountGreaterThanZero();

    error LockupFactory__InvalidTimestamps(uint256 index, uint40 previousTimestamp, uint40 currentTimestamp);
}
