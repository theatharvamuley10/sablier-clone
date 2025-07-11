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
import {LockupManager} from "./LockupManager.sol";

/*
████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗                              
╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║                              
   ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║                              
   ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║                              
   ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║                              
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝                              
                                                                          
███████╗████████╗██████╗ ███████╗ █████╗ ███╗   ███╗██╗███╗   ██╗ ██████╗ 
██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔════╝ 
███████╗   ██║   ██████╔╝█████╗  ███████║██╔████╔██║██║██╔██╗ ██║██║  ███╗
╚════██║   ██║   ██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║██║██║╚██╗██║██║   ██║
███████║   ██║   ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║╚██████╔╝
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                          
██╗      ██████╗  ██████╗██╗  ██╗██╗   ██╗██████╗                         
██║     ██╔═══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗                        
██║     ██║   ██║██║     █████╔╝ ██║   ██║██████╔╝                        
██║     ██║   ██║██║     ██╔═██╗ ██║   ██║██╔═══╝                         
███████╗╚██████╔╝╚██████╗██║  ██╗╚██████╔╝██║                             
╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝                                                                                 
*/

contract LockupFactory is ILockupStream, LockupManager {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    constructor(string memory name_, string memory symbol_) LockupManager(name_, symbol_) {}

    /*//////////////////////////////////////////////////////////////////////////
                           EXTERNAL NON CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function userCreateLL(
        Lockup.UserInput calldata params,
        Lockup_Linear.Durations calldata durations,
        Lockup_Linear.UnlockAmounts calldata unlockAmounts
    ) external returns (uint256 streamId) {
        Helpers.checkCommonInputsValid(params);

        Lockup.TimeStamps memory timestamps = Lockup.TimeStamps({start: uint40(block.timestamp), end: 0});

        uint40 cliffTime;

        if (durations.cliff > 0) cliffTime = timestamps.start + durations.cliff;
        timestamps.end = timestamps.start + durations.total;

        streamId = _createLL(
            Lockup.UserInputWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                token: params.token,
                totalAmount: params.totalAmount,
                shape: params.shape,
                timestamps: timestamps
            }),
            unlockAmounts,
            cliffTime
        );
    }

    function _createLL(
        Lockup.UserInputWithTimestamps memory params,
        Lockup_Linear.UnlockAmounts memory unlockAmounts,
        uint40 cliffTime
    ) internal returns (uint256 streamId) {
        Helpers.checkLinearLockupIsValid(params, unlockAmounts, cliffTime);

        streamId = nextStreamId;

        if (unlockAmounts.start > 0) {
            _unlockAmounts[streamId].start = unlockAmounts.start;
        }

        if (cliffTime > 0) {
            _cliffs[streamId] = cliffTime;
            if (unlockAmounts.cliff > 0) {
                _unlockAmounts[streamId].cliff = unlockAmounts.cliff;
            }
        }

        executeCreateStream(params, streamId);
        unchecked {
            nextStreamId += 1;
        }

        emit CreateLinearLockupStream(
            streamId,
            params, // being called from storage - gas expensive
            unlockAmounts,
            cliffTime
        );
    }

    function userCreateLT(
        Lockup.UserInput calldata params,
        Lockup_Tranche.TrancheWithDuration[] calldata tranchesWithDurations
    ) external returns (uint256 streamId) {
        Helpers.checkCommonInputsValid(params);

        Lockup.TimeStamps memory timestamps = Lockup.TimeStamps({start: uint40(block.timestamp), end: 0});

        Lockup_Tranche.TrancheWithTimestamps[] memory tranches =
            Helpers.calculateTranchesWithTimestamps(tranchesWithDurations, timestamps.start);

        timestamps.end = tranches[tranches.length - 1].timestamp;

        streamId = _createLT(
            Lockup.UserInputWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                token: params.token,
                totalAmount: params.totalAmount,
                shape: params.shape,
                timestamps: timestamps
            }),
            tranches
        );
    }

    function _createLT(
        Lockup.UserInputWithTimestamps memory params,
        Lockup_Tranche.TrancheWithTimestamps[] memory tranches
    ) internal returns (uint256 streamId) {
        Helpers.checkTrancheLockupIsValid(params, tranches);

        streamId = nextStreamId;

        uint256 totalTrancheCount = tranches.length;
        for (uint256 i = 0; i < totalTrancheCount; i++) {
            _tranches[streamId].push(tranches[i]);
        }

        executeCreateStream(params, streamId);
        unchecked {
            nextStreamId += 1;
        }
        emit CreateTrancheLockupStream(
            streamId,
            params, // being called from storage - gas expensive
            tranches
        );
    }

    function userCreateLD(
        Lockup.UserInput calldata params,
        Lockup_Dynamic.SegmentsWithDurations[] calldata segmentsWithDurations
    ) external returns (uint256 streamId) {
        Helpers.checkCommonInputsValid(params);

        Lockup.TimeStamps memory timestamps = Lockup.TimeStamps({start: uint40(block.timestamp), end: 0});

        Lockup_Dynamic.SegmentsWithTimestamps[] memory segments =
            Helpers.calculateSegmentsWithTimestamps(segmentsWithDurations, timestamps.start);

        timestamps.end = segments[segments.length - 1].timestamp;

        streamId = _createLD(
            Lockup.UserInputWithTimestamps({
                sender: params.sender,
                recipient: params.recipient,
                token: params.token,
                totalAmount: params.totalAmount,
                shape: params.shape,
                timestamps: timestamps
            }),
            segments
        );
    }

    function _createLD(
        Lockup.UserInputWithTimestamps memory params,
        Lockup_Dynamic.SegmentsWithTimestamps[] memory segments
    ) internal returns (uint256 streamId) {
        Helpers.checkDynamicLockupIsValid(params, segments);

        streamId = nextStreamId;

        uint256 totalSegmentCount = segments.length;
        for (uint256 i = 0; i < totalSegmentCount; i++) {
            _segments[streamId].push(segments[i]);
        }

        executeCreateStream(params, streamId);
        unchecked {
            nextStreamId += 1;
        }
        emit CreateDynamicLockupStream(
            streamId,
            params, // being called from storage - gas expensive
            segments
        );
    }

    function executeCreateStream(Lockup.UserInputWithTimestamps memory params, uint256 streamId) internal {
        _streams[streamId] = Lockup.Stream({
            streamId: streamId,
            sender: params.sender,
            recipient: params.recipient,
            token: params.token,
            startTime: params.timestamps.start,
            endTime: params.timestamps.end,
            amounts: Lockup.Amounts({deposited: params.totalAmount, withdrawn: 0, refunded: 0}),
            shape: params.shape
        });

        _mint({to: params.recipient, tokenId: streamId});

        params.token.safeTransferFrom({from: msg.sender, to: address(this), value: params.totalAmount});
    }
}
