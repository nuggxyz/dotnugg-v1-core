// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import {DotnuggV1Resolver} from "./DotnuggV1Resolver.sol";

import {IDotnuggV1Storage} from "./interfaces/IDotnuggV1Storage.sol";
import {DotnuggV1Calculated, DotnuggV1Read} from "./interfaces/DotnuggV1Files.sol";

import {ShiftLib} from "./libraries/ShiftLib.sol";
import {DotnuggV1FileStorage} from "./core/DotnuggV1FileStorage.sol";

import "./_test/utils/forge.sol";

contract DotnuggV1Storage is IDotnuggV1Storage, DotnuggV1Resolver {
    address public immutable factory;

    address public trusted;

    constructor() {
        factory = address(this);

        trusted = address(this);
    }

    function init(address _trusted) external {
        require(trusted == address(0) && msg.sender == factory, "C:0");

        trusted = _trusted;
    }

    function updateTrusted(address _trusted) external {
        require(trusted == msg.sender, "C:0");

        trusted = _trusted;
    }

    function lengthOf(uint8 feature) public override returns (uint8 a) {
        address ptr = DotnuggV1FileStorage.location(feature);

        assembly {
            extcodecopy(ptr, 0x1F, 0x01, 0x01)

            a := mload(0x00)

            mstore(0x00, 0x00)
        }
    }

    function fun(address ptr) external pure {}

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                  write
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function exec(uint8[8] memory ids, bool base64) public returns (string memory) {
        return svg(calc(read(ids)), base64);
    }

    function exec(
        uint8 feature,
        uint8 pos,
        bool base64
    ) public returns (string memory) {
        return svg(calc(read(feature, pos)), base64);
    }

    uint16 internal constant DATA_PRE_OFFSET = 1; // We skip the first byte as it's a STOP opcode to ensure the contract can't be called.

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                WRITE TO STORAGE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function write(bytes[] calldata data) external {
        require(data.length == 8, "nope");
        for (uint8 i = 0; i < 8; i++) {
            if (data[i].length > 0) write(i, data[i]);
        }
    }

    function write(uint8 feature, bytes calldata data) public override {
        require(trusted == msg.sender, "C:0");

        require(feature < 8, "F:3");

        DotnuggV1FileStorage.save(data, feature);

        uint8 len = lengthOf(feature);

        require(len > 0, "F:0");

        emit Write(feature, len, msg.sender);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                READ FROM STORAGE
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function read(uint8[8] memory ids) public returns (DotnuggV1Read[8] memory res) {
        for (uint8 i = 0; i < 8; i++) {
            if (ids[i] != 0) res[i] = read(i, ids[i]);
        }
    }

    // there can only be max 255 items per feature, and so num can not be higher than 255
    function read(uint8 feature, uint8 num) public returns (DotnuggV1Read memory res) {
        require(num != 0 && num <= lengthOf(feature), "F:1");

        num = num - 1;

        res.dat = DotnuggV1FileStorage.fetch(feature, num);

        return res;

        // address _pointer = pointerOf(feature);

        // uint8 len = lengthOf(feature);
        // // PUSH1 32
        // // PUSH1 02     2
        // // RETSIZE      0 2
        // // CALLDATALOAD I 2
        // // DUP2         2 I 2
        // // MUL          M 2
        // // DUP          M M 2
        // // DUP3         2 M M 2
        // // ADD          A M 2
        // // DUP3         2 A M 2
        // // DUP          2
        // // ADD          4 A M 2
        // // DUP          4 4 A M 2
        // // DUP6         X 4 4 A M 2
        // // DUP5         M X 4 4 A M 2
        // // DUP2
        // // -----
        // // PUSH05
        // // ADD
        // // ADD          01
        // // SWAP         90
        // // CODECOPY     4 A M 2
        // // DUP4         2 4 A M 2
        // // MLOAD        S 4 A M 2
        // // RETSIZE      0 S 4 A M 2
        // // DUP5         2 0 S 4 A M 2
        // // MSTORE       S 4 A M 2
        // // DUP          S S 4 A M 2
        // // SWA2P2       4 S S A M 2
        // // MLOAD        E S S A M 2
        // // SUB          Z S A M 2
        // // DUP          Z Z S
        // // ---- SWAP         S Z Z
        // // --- DUP3         S Z Z S
        // // DUP4         X Z Z S
        // // MOD          M Z S
        // // DUP7         X M Z S
        // // SUB          E Z S
        // // DUP2         Z E Z S
        // // DUP4         S Z E Z S
        // // DUP2         E S Z E Z S
        // // RETSIZE      0 E Z E Z S
        // // CODE COPY    E Z S
        // // ADD          L
        // // RETSIZE      0 Z
        // // RETURN
        // // 6020_6002_3D_35_81_02_80_82_01_82_80_01_80_85_84_81_600f_01_01_90_39_83_51_3D_85_52_80_91_51_03_80_86_06_86_03_81_83_82_3D_39_01_3D_F3
        // // 0x6002_3D_35_81_02_80_82_01_82_80_01_80_6020_84_01_90_39_83_51_3D_84_82_52_80_91_52_03_80_90_3D_39;

        // // read first byte of calldata
        // // multiply it by 2
        // // store it
        // // store it + 2
        // // read start at load(it)
        // // read end load(it + 2)
        // // code copy 0 start (end-start)
        // // return 0 (end-start)
        // assembly {
        //     log1(0x00, 0x90, _pointer)

        //     let index := add(add(DATA_PRE_OFFSET, 0x01), mul(num, 2))

        //     let dataStart := add(mul(len, 0x2), DATA_PRE_OFFSET)

        //     // mstore(0x00, 0x00)

        //     extcodecopy(_pointer, 0x1E, index, 0x2)

        //     let start := add(mload(0x00), dataStart)
        //     let end := 0

        //     switch eq(len, add(num, 1))
        //     case 1 {
        //         end := extcodesize(_pointer)
        //     }
        //     default {
        //         extcodecopy(_pointer, 0x1E, add(index, 2), 0x2)
        //         end := add(mload(0x00), dataStart)
        //     }

        //     let size := sub(end, start)

        //     let extra := sub(0x20, mod(size, 0x20))

        //     let trusize := add(extra, size)

        //     if iszero(eq(0, mod(trusize, 0x20))) {
        //         mstore(0x0, 0xffffffff)
        //         revert(0x0, 0x20)
        //     }

        //     let ret := add(size, add(0x20, extra))

        //     let ptr := mload(0x40)

        //     mstore(0x40, add(ptr, ret))

        //     mstore(ptr, div(trusize, 0x20))

        //     extcodecopy(_pointer, add(ptr, add(0x20, extra)), start, size)

        //     // log1(ptr, ret, res)

        //     mstore(res, ptr)

        //     // log1(res, ret, ptr)
        // }
    }

    function pointerOf(uint8 feature) public override returns (address res) {
        return DotnuggV1FileStorage.location(feature);
    }
}
