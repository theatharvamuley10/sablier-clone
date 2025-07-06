//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Lockup {
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
        address sender;
        address recipient;
        IERC20 token;
        uint256 startTime;
        uint256 endTime;
        Amounts amounts;
    }

    /// @param sender    The creator of stream who is sending the amounts
    /// @param recipient The recipient of the streamed amounts
    /// @param token     The ERC20 token that is being streamed
    struct UserInput {
        address sender;
        address recipient;
        IERC20 token;
    }
}

library Lockup_Linear {
    /// @param start The start time of the stream
    /// @param end   The end time of the stream
    /// @param cliff The cliff time of the stream
    struct TimeStamps {
        uint256 start;
        uint256 end;
        uint256 cliff;
    }

    /// @param total The total duration of the stream
    /// @param cliff The cliff duration of the stream
    struct Durations {
        uint256 total;
        uint256 cliff;
    }

    /// @param start The amount to be unlocked at the start of the stream
    /// @param cliff The amount to be unlocked at clifftime
    struct UnlockAmounts {
        uint256 start;
        uint256 cliff;
        uint256 total;
    }

    /// @dev all parameters if LockupLinear in one place for all in one check
    struct StreamLL {
        address sender;
        address recipient;
        IERC20 token;
        TimeStamps timeStamps;
        UnlockAmounts unlockAmounts;
    }
}
