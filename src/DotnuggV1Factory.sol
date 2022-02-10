// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {DotnuggV1Storage} from "./DotnuggV1Storage.sol";

import {IDotnuggV1Storage} from "./interfaces/IDotnuggV1Storage.sol";

/// @title dotnugg V1 - onchain encoder/decoder protocol for dotnugg files
/// @author nugg.xyz - danny7even & dub6ix
/// @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
/// @dev hold my margarita
contract DotnuggV1Factory {
    DotnuggV1Storage public immutable template;

    constructor() {
        template = new DotnuggV1Storage();
    }

    function register() external returns (IDotnuggV1Storage proxy) {
        proxy = deploy();

        proxy.init(msg.sender);
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function deploy() internal returns (IDotnuggV1Storage instance) {
        DotnuggV1Storage base = template;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, base))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(address(instance) != address(0), "ERC1167: create2 failed");
    }
}
