// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {IDotnuggV1Storage} from "./IDotnuggV1Storage.sol";

interface IDotnuggV1Factory {
    function register() external returns (IDotnuggV1Storage proxy);
}