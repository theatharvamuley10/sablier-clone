//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*//////////////////////////////////////////////////////////////////////////
                           COMMON DATA TYPES
//////////////////////////////////////////////////////////////////////////*/

library Lockup {
    enum StreamShape {
        LINEAR,
        DYNAMIC,
        TRANCHED
    }

    /// @param deposited The total amount deposited in the stream by sender
    /// @param withdraw  The total amount withdrawn from the stream to recipient
    /// @param refunded  The total amount refunded from the stream to sender
    struct Amounts {
        uint256 deposited;
        uint256 withdrawn;
        uint256 refunded;
    }

    /// @param sender    The creator of stream who is sending the amounts
    /// @param recipient The recipient of the streamed amounts
    /// @param token     The ERC20 token that is being streamed
    /// @param startTime The start time of the stream
    /// @param endTime   The end time of the stream
    /// @param amounts   The status of deposited, withdrawn, refunded amounts of the stream
    struct Stream {
        uint256 streamId;
        address sender;
        address recipient;
        IERC20 token;
        uint40 startTime;
        uint40 endTime;
        Amounts amounts;
        string shape;
    }

    /// @param sender    The creator of stream who is sending the amounts
    /// @param recipient The recipient of the streamed amounts
    /// @param token     The ERC20 token that is being streamed
    struct UserInput {
        address sender;
        address recipient;
        IERC20 token;
        uint256 totalAmount;
        string shape;
    }

    /// @param sender    The creator of stream who is sending the amounts
    /// @param recipient The recipient of the streamed amounts
    /// @param token     The ERC20 token that is being streamed
    struct UserInputWithTimestamps {
        address sender;
        address recipient;
        IERC20 token;
        uint256 totalAmount;
        string shape;
        TimeStamps timestamps;
    }

    /// @param start The start time of the stream
    /// @param end   The end time of the stream
    struct TimeStamps {
        uint40 start;
        uint40 end;
    }
}

/*//////////////////////////////////////////////////////////////////////////
                           LOCKUP LINEAR
//////////////////////////////////////////////////////////////////////////*/

library Lockup_Linear {
    /// @param total The total duration of the stream
    /// @param cliff The cliff duration of the stream
    struct Durations {
        uint40 cliff;
        uint40 total;
    }

    /// @param start The amount to be unlocked at the start of the stream
    /// @param cliff The amount to be unlocked at clifftime
    struct UnlockAmounts {
        uint256 start;
        uint256 cliff;
    }
}

/*//////////////////////////////////////////////////////////////////////////
                           LOCKUP TRANCHE
//////////////////////////////////////////////////////////////////////////*/

library Lockup_Tranche {
    /// @param amount The total amount of tranche
    /// @param duration The duration of tranche
    struct TrancheWithDuration {
        uint256 amount;
        uint40 duration;
    }

    /// @param amount The total amount of tranche
    /// @param timestamp The timestamp of end of tranche
    struct TrancheWithTimestamps {
        uint256 amount;
        uint40 timestamp;
    }
}

/*//////////////////////////////////////////////////////////////////////////
                           LOCKUP DYNAMIC
//////////////////////////////////////////////////////////////////////////*/

library Lockup_Dynamic {
    /// @param total The total duration of the stream
    /// @param cliff The cliff duration of the stream
    struct SegmentsWithDurations {
        uint256 amount;
        uint40 duration;
        uint256 exponent;
    }

    /// @param total The total duration of the stream
    /// @param cliff The cliff duration of the stream
    struct SegmentsWithTimestamps {
        uint256 amount;
        uint40 timestamp;
        uint256 exponent;
    }
}
