// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {IDotnuggV1Processor} from './interfaces/IDotnuggV1Processor.sol';
import {IDotnuggV1Data} from './interfaces/IDotnuggV1Data.sol';
import {IDotnuggV1Resolver} from './interfaces/IDotnuggV1Resolver.sol';
import {IDotnuggV1Implementer} from './interfaces/IDotnuggV1Implementer.sol';

import {DotnuggV1Storage} from './logic/DotnuggV1Storage.sol';

import {DotnuggV1Lib} from './DotnuggV1Lib.sol';

/// @title dotnugg Processor V1 - onchain encoder/decoder protocol for dotnugg files
/// @author nugg.xyz - danny7even & dub6ix
/// @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
/// @dev hold my margarita
contract DotnuggV1Processor is IDotnuggV1Processor, DotnuggV1Storage {
    DotnuggV1Lib public lib;

    constructor() {
        lib = new DotnuggV1Lib();
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                     core
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function process(
        address implementer,
        uint256 tokenId,
        uint8 width
    ) public view override returns (uint256[] memory resp, IDotnuggV1Data.Data memory dat) {
        IDotnuggV1Data.Data memory data = IDotnuggV1Implementer(implementer).dotnuggV1Callback(tokenId);

        uint256[][] memory files = getBatchFiles(implementer, data.ids);

        dat = data;

        resp = processCore(files, data, width);
    }

    function processCore(
        uint256[][] memory files,
        IDotnuggV1Data.Data memory data,
        uint8 width
    ) public view override returns (uint256[] memory resp) {
        return lib.processCore(files, data, width);
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                resolvers
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function resolveRaw(
        uint256[] memory file,
        IDotnuggV1Data.Data memory,
        uint8
    ) public pure override returns (uint256[] memory res) {
        res = file;
    }

    function resolveBytes(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8
    ) public pure override returns (bytes memory res) {
        res = abi.encode(file, data);
    }

    function resolveData(
        uint256[] memory,
        IDotnuggV1Data.Data memory data,
        uint8
    ) public pure override returns (IDotnuggV1Data.Data memory res) {
        res = data;
    }

    function resolveString(
        uint256[] memory file,
        IDotnuggV1Data.Data memory,
        uint8 zoom
    ) public view override returns (string memory) {
        bytes memory working = lib.buildSvg(file, zoom);

        return string(working);
    }

    function resolveUri(
        uint256[] memory file,
        IDotnuggV1Data.Data memory data,
        uint8 zoom
    ) public view override returns (string memory res) {
        res = string(
            lib.jsonBase64(
                abi.encodePacked(
                    '{"name":"',
                    data.name,
                    '","description":"',
                    data.desc,
                    '", "image": "',
                    lib.buildSvg(file, zoom),
                    '","DotnuggVersion":"',
                    lib.uintToAscii(data.version),
                    '","tokenId":"',
                    lib.uintToAscii(data.tokenId),
                    '","proof":"',
                    lib.uintToHex(data.proof, 32),
                    '","owner":"',
                    lib.uintToHex(uint160(data.owner), 20),
                    '"}'
                )
            )
        );
    }

    /* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                full processors
       ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */

    function dotnuggToUri(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view override returns (address resolvedBy, string memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            try IDotnuggV1Resolver(resolver).resolveUri(file, data, zoom) returns (string memory d) {
                return (resolver, d);
            } catch (bytes memory) {}
        }

        return (address(this), resolveUri(file, data, zoom));
    }

    function dotnuggToRaw(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view override returns (address resolvedBy, uint256[] memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            try IDotnuggV1Resolver(resolver).resolveRaw(file, data, zoom) returns (uint256[] memory d) {
                return (resolver, d);
            } catch (bytes memory) {}
        }

        return (address(this), resolveRaw(file, data, zoom));
    }

    function dotnuggToBytes(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view override returns (address resolvedBy, bytes memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            try IDotnuggV1Resolver(resolver).resolveBytes(file, data, zoom) returns (bytes memory d) {
                return (resolver, d);
            } catch (bytes memory) {}
        }

        return (address(this), resolveBytes(file, data, zoom));
    }

    function dotnuggToString(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view override returns (address resolvedBy, string memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            try IDotnuggV1Resolver(resolver).resolveString(file, data, zoom) returns (string memory d) {
                return (resolver, d);
            } catch (bytes memory) {}
        }

        return (address(this), resolveString(file, data, zoom));
    }

    function dotnuggToData(
        address implementer,
        uint256 tokenId,
        address resolver,
        uint8 width,
        uint8 zoom
    ) external view override returns (address resolvedBy, IDotnuggV1Data.Data memory res) {
        (uint256[] memory file, IDotnuggV1Data.Data memory data) = process(implementer, tokenId, width);

        if (resolver != address(0)) {
            try IDotnuggV1Resolver(resolver).resolveData(file, data, zoom) returns (IDotnuggV1Data.Data memory d) {
                return (resolver, d);
            } catch (bytes memory) {}
        }

        return (address(this), resolveData(file, data, zoom));
    }
}
