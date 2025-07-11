// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin-contracts/interfaces/IERC20.sol";
import {ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";
import {SafeERC20} from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import {Lockup} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";
import {Lockup_Tranche} from "src/libraries/DataTypes.sol";
import {Lockup_Dynamic} from "src/libraries/DataTypes.sol";
import {Errors} from "../libraries/Errors.sol";
import {Helpers} from "src/libraries/Helpers.sol";

interface ILockupStream {
    event CreateLinearLockupStream(
        uint256 indexed streamId,
        Lockup.UserInputWithTimestamps commonParams,
        Lockup_Linear.UnlockAmounts unlockAmounts,
        uint256 clifftime
    );

    event CreateTrancheLockupStream(
        uint256 indexed streamId,
        Lockup.UserInputWithTimestamps commonParams,
        Lockup_Tranche.TrancheWithTimestamps[] tranches
    );

    event CreateDynamicLockupStream(
        uint256 indexed streamId,
        Lockup.UserInputWithTimestamps commonParams,
        Lockup_Dynamic.SegmentsWithTimestamps[] segments
    );
}
