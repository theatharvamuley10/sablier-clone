// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts/interfaces/IERC20.sol";
import {ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {Lockup} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";
import {Lockup_Tranche} from "src/libraries/DataTypes.sol";
import {Lockup_Dynamic} from "src/libraries/DataTypes.sol";
import {Errors} from "./libraries/Errors.sol";
import {Helpers} from "src/libraries/Helpers.sol";
import {ILockupStream} from "src/interfaces/ILockupStream.sol";

abstract contract LockupManager is ERC721 {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Counter for stream ids. Used in create functions
    uint256 internal nextStreamId = 1;

    /// @dev Stream Data mapped by stream IDs. This is common for all stream shapes.
    mapping(uint256 streamId => Lockup.Stream stream) internal _streams;

    /// @dev Cliff timestamp mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => uint256 cliffTime) internal _cliffs;

    /// @dev Unlock amounts mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => Lockup_Linear.UnlockAmounts unlockAmounts) internal _unlockAmounts;

    /// @dev Unlock amounts mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => Lockup_Tranche.TrancheWithTimestamps[] tranches) internal _tranches;

    /// @dev Unlock amounts mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => Lockup_Dynamic.SegmentsWithTimestamps[] segments) internal _segments;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /*//////////////////////////////////////////////////////////////////////////
                           EXTERNAL NON CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    // function createStream(Lockup.Stream memory stream) internal {
    //     _streams[streamId] = stream;
    // }

    // function createStreamLL(
    //     uint256 cliffTime,
    //     Lockup_Linear.UnlockAmounts memory unlockAmounts
    // ) internal {
    //     _cliffs[streamId] = cliffTime;
    //     _unlockAmounts[streamId] = unlockAmounts;
    // }

    /*//////////////////////////////////////////////////////////////////////////
                           EXTERNAL NON CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/
}
