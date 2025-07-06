// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Lockup} from "src/libraries/DataTypes.sol";
import {Lockup_Linear} from "src/libraries/DataTypes.sol";
import {IERC20} from "@openzeppelin-contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";
import {Errors} from "./libraries/Errors.sol";
import {Helpers} from "src/libraries/Helpers.sol";
import {ERC721} from "@openzeppelin-contracts/token/ERC721/ERC721.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗ 
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝
                                                   
 ██████╗██╗      ██████╗ ███╗   ██╗███████╗        
██╔════╝██║     ██╔═══██╗████╗  ██║██╔════╝        
██║     ██║     ██║   ██║██╔██╗ ██║█████╗          
██║     ██║     ██║   ██║██║╚██╗██║██╔══╝          
╚██████╗███████╗╚██████╔╝██║ ╚████║███████╗        
 ╚═════╝╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝        

*/

contract LockupStream is ERC721 {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Counter for stream ids. Used in create functions
    uint256 private streamId = 1;

    /// @dev Cliff timestamp mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => uint256 cliffTime) internal _cliffs;

    /// @dev Unlock amounts mapped by stream IDs. This is used in Lockup Linear models.
    mapping(uint256 streamId => Lockup_Linear.UnlockAmounts unlockAmounts)
        internal _unlockAmounts;

    /// @dev Stream Data mapped by stream IDs. This is common for all stream shapes.
    mapping(uint256 streamId => Lockup.Stream stream) internal _streams;

    event CreateStream(
        uint256 streamId,
        Lockup.Stream stream,
        Lockup_Linear.UnlockAmounts unlockAmounts,
        uint256 cliffTime
    );

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    function userCreateLL(
        Lockup.UserInput memory params,
        Lockup_Linear.Durations memory durations,
        Lockup_Linear.UnlockAmounts memory unlockAmountsLL
    ) external {
        Lockup_Linear.TimeStamps memory timeStampsLL;

        timeStampsLL.start = block.timestamp;
        timeStampsLL.end = timeStampsLL.start + durations.total;
        timeStampsLL.cliff = timeStampsLL.start + durations.cliff;

        Lockup_Linear.StreamLL memory streamLL;
        streamLL = Lockup_Linear.StreamLL({
            sender: params.sender,
            recipient: params.recipient,
            token: params.token,
            timeStamps: timeStampsLL,
            unlockAmounts: unlockAmountsLL
        });

        Helpers.checkLinearLockupIsValid(streamLL);

        stateChangesLL(streamLL);
    }

    function stateChangesLL(Lockup_Linear.StreamLL memory streamLL) internal {
        Lockup.Amounts memory amounts = Lockup.Amounts({
            deposited: streamLL.unlockAmounts.total,
            withdrawn: 0,
            refunded: 0
        });

        Lockup.Stream memory stream;
        stream = Lockup.Stream({
            sender: streamLL.sender,
            recipient: streamLL.recipient,
            token: streamLL.token,
            startTime: streamLL.timeStamps.start,
            endTime: streamLL.timeStamps.end,
            amounts: amounts
        });

        _streams[streamId] = stream;

        _cliffs[streamId] = streamLL.timeStamps.cliff;

        _unlockAmounts[streamId] = streamLL.unlockAmounts;

        createStream(
            streamLL.sender,
            streamLL.recipient,
            streamLL.unlockAmounts.total,
            streamLL.token
        );

        emit CreateStream(
            streamId - 1,
            _streams[streamId],
            _unlockAmounts[streamId],
            _cliffs[streamId]
        );
    }

    function createStream(
        address sender,
        address recipient,
        uint256 amount,
        IERC20 token
    ) internal {
        token.safeTransferFrom(sender, address(this), amount);

        _mint(recipient, streamId);

        streamId += 1;
    }
}
