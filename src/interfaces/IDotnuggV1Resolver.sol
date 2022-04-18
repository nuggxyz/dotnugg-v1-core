// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.13;

interface IDotnuggV1Resolver {
    function calc(uint256[][] memory reads) external view returns (uint256[] memory calculated);

    function combo(uint256[][] memory reads, bool base64) external view returns (string memory data);

    function supersize(uint256[][][] memory reads, bool base64) external view returns (string[] memory res);

    function svg(uint256[] memory calculated, bool base64) external view returns (string memory data);

    function encodeJsonAsBase64(bytes memory input) external view returns (bytes memory data);

    function encodeJsonAsUtf8(bytes memory input) external view returns (bytes memory data);

    function encodeSvgAsBase64(bytes memory input) external view returns (bytes memory data);

    function encodeSvgAsUtf8(bytes memory input) external view returns (bytes memory data);

    function props(uint8[8] memory input, string[8] memory labels) external view returns (string memory);

    // function decodeProof(uint256 input) external view returns (uint16[16] memory res);

    // function encodeProof(uint8[8] memory ids) external view returns (uint256 proof);

    // function encodeProof(uint16[16] memory ids) external view returns (uint256 proof);

    // function decodeProofCore(uint256 proof) external view returns (uint8[8] memory res);

    // function parseItemIdAsString(uint16 itemId, string[8] memory labels) external view returns (string memory);
}
