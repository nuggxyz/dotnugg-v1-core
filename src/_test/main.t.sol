// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;

import "./utils/forge.sol";

import "../DotnuggV1.sol";

contract t is ForgeTest {
    DotnuggV1 factory;

    constructor() {
        ds.setDsTest(address(this));
    }

    function reset() internal {
        factory = new DotnuggV1();
    }
}
