// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Metadata} from './IDotnuggV1Metadata.sol';

interface IDotnuggV1Implementer {
    function dotnuggV1ImplementerCallback(uint256 artifactId) external view returns (IDotnuggV1Metadata.Memory memory data);

    function dotnuggV1TrustCallback(address caller) external returns (bool);
}
