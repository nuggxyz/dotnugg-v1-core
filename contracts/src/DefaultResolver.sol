// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;
import 'hardhat/console.sol';
import './interfaces/IDotNugg.sol';
import './interfaces/IResolver.sol';

import './logic/Calculator.sol';
import './logic/Matrix.sol';
import './logic/Svg.sol';

import './v2/Merge.sol';

import './interfaces/IResolver.sol';
import './libraries/Base64.sol';

import './types/Version.sol';

/**
 * @title DotNugg V1 - onchain encoder/decoder for dotnugg files
 * @author Nugg Labs - @danny7even & @dub6ix
 * @notice yoU CAN'T HaVe ImAgES oN THe BlOCkcHAIn
 * @dev hold my margarita
 */
contract DefaultResolver is INuggFtProcessor {
    IPostProcessResolver public immutable override postProcessor;

    IProcessResolver public immutable override processor;

    IPreProcessResolver public immutable override preProcessor;

    constructor() {
        postProcessor = IPostProcessResolver(address(this));
        preProcessor = IPreProcessResolver(address(this));
        processor = IProcessResolver(address(this));
    }

    function preProcess(bytes memory) public pure override returns (bytes memory _res) {
        _res = '';
    }

    function process(
        uint256[][] memory files,
        bytes memory,
        bytes memory
    ) public view override returns (uint256[] memory resp) {
        // (uint256 tokenId, uint256 data) = abi.decode(data, ( uint256[][]));
        //
        Version.Memory[][] memory versions = Version.parse(files);

        // if (old) {
        IDotNugg.Matrix memory old = Calculator.combine(8, 63, uint256(0), versions);

        resp = Version.bigMatrixWithData(old.version);

        // return abi.encode(mat.width, mat.height, result.bigmatrix);
        // } else {
        //     Version.Memory memory result = Merge.begin(versions, 33);
        //     (uint256 width, uint256 height) = Version.getWidth(result);
        //     // return abi.encode(width, height, result.bigmatrix);
        //                 return abi.encode( result.bigmatrix);

        // // }
    }

    function postProcess(
        uint256[] memory file,
        bytes memory data,
        bytes memory
    ) public view override returns (bytes memory res) {
        (uint256 tokenId, uint256 itemData, address owner) = abi.decode(data, (uint256, uint256, address));

        uint256 width = (file[file.length - 1] >> 63) & ShiftLib.mask(6);
        uint256 height = (file[file.length - 1] >> 69) & ShiftLib.mask(6);

        console.log(width, height);

        res = Svg.buildSvg(file, width, height);

        res = Base64._encode(res);

        res = abi.encodePacked(
            Base64.PREFIX_JSON,
            Base64._encode(
                bytes(
                    abi.encodePacked(
                        '{"name":"',
                        'NuggFT',
                        '","tokenId":"',
                        Uint256.toString(tokenId),
                        '","description":"',
                        'The Nuggiest FT',
                        '","itemData":"',
                        Uint256.toHexString(itemData, 32),
                        '","owner":"',
                        Uint256.toHexString(uint160(owner), 20),
                        '", "image": "',
                        Base64.PREFIX_SVG,
                        res,
                        '"}'
                    )
                )
            )
        );
    }

    function supportsInterface(bytes4 interfaceId) public pure override(INuggFtProcessor) returns (bool) {
        return
            interfaceId == type(INuggFtProcessor).interfaceId ||
            interfaceId == type(IProcessResolver).interfaceId ||
            interfaceId == type(IPreProcessResolver).interfaceId ||
            interfaceId == type(IPostProcessResolver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
