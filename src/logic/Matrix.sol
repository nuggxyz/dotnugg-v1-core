// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Types} from '../types/Types.sol';

import '../libraries/Bytes.sol';
import '../logic/Rgba.sol';

import '../types/Version.sol';

library Matrix {
    using Bytes for bytes;
    using Rgba for Types.Rgba;
    using Event for uint256;
    using Version for Version.Memory;

    // function update(Types.Matrix memory matrix) internal pure returns (Version.Memory memory m) {
    //     Version.initBigMatrix(m, matrix.width);

    //     resetIterator(matrix);

    //     for (uint256 index = 0; index < uint256(matrix.width) * uint256(matrix.height); index++) {
    //         Matrix.next(matrix);
    //         Types.Pixel memory pix = Matrix.current(matrix);

    //         // if (pix.exists) {
    //         uint256 color = (uint256(pix.rgba.r) << 24);
    //         color |= (uint256(pix.rgba.g) << 16);
    //         color |= (uint256(pix.rgba.b) << 8);
    //         color |= (uint256(pix.rgba.a));
    //         Version.setBigMatrixPixelAt(m, index, color);
    //         // }
    //     }

    //     m.data |= (uint256(matrix.width) << 63);
    //     m.data |= (uint256(matrix.height) << 69);
    // }

    function create(uint8 width, uint8 height) internal pure returns (Types.Matrix memory res) {
        require(width % 2 == 1 && height % 2 == 1, 'ML:C:0');

        Version.initBigMatrix(res.version, width);
        res.version.setWidth(width, height);

        // res.data = new Types.Pixel[][](height);
        // for (uint8 i = 0; i < height; i++) {
        //     res.data[i] = new Types.Pixel[](width);
        // }
    }

    function moveTo(
        Types.Matrix memory matrix,
        uint8 xoffset,
        uint8 yoffset,
        uint8 width,
        uint8 height
    ) internal pure {
        matrix.currentUnsetX = xoffset;
        matrix.currentUnsetY = yoffset;
        matrix.startX = xoffset;
        matrix.width = width + xoffset;
        matrix.height = height + yoffset;
    }

    function next(Types.Matrix memory matrix) internal pure returns (bool res) {
        res = next(matrix, matrix.width);
    }

    function next(Types.Matrix memory matrix, uint8 width) internal pure returns (bool res) {
        if (matrix.init) {
            if (width <= matrix.currentUnsetX + 1) {
                if (matrix.height == matrix.currentUnsetY + 1) {
                    return false;
                }
                matrix.currentUnsetX = matrix.startX; // 0 by default
                matrix.currentUnsetY++;
            } else {
                matrix.currentUnsetX++;
            }
        } else {
            matrix.init = true;
        }
        res = true;
    }

    function current(Types.Matrix memory matrix) internal pure returns (uint256 res) {
        res = matrix.version.getBigMatrixPixelAt(matrix.currentUnsetX, matrix.currentUnsetY);
    }

    function setCurrent(Types.Matrix memory matrix, uint256 pixel) internal pure {
        matrix.version.setBigMatrixPixelAt(matrix.currentUnsetX, matrix.currentUnsetY, pixel);
    }

    function resetIterator(Types.Matrix memory matrix) internal pure {
        matrix.currentUnsetX = 0;
        matrix.currentUnsetY = 0;
        matrix.startX = 0;
        matrix.init = false;
    }

    function moveBack(Types.Matrix memory matrix) internal pure {
        (uint256 width, uint256 height) = matrix.version.getWidth();
        matrix.width = uint8(width);
        matrix.height = uint8(height);
    }

    function set(
        Types.Matrix memory matrix,
        Version.Memory memory data,
        uint256 groupWidth,
        uint256 groupHeight
    ) internal view {
        matrix.height = uint8(groupHeight);
        uint256 feature = data.getFeature();

        for (uint256 y = 0; y < groupHeight; y++) {
            for (uint256 x = 0; x < groupWidth; x++) {
                next(matrix, uint8(groupWidth));
                uint256 col = Version.getPixelAt(data, x, y);
                if (col != 0) {
                    (, uint256 color, uint256 zindex) = Version.getPalletColorAt(data, col);
                    // (zindex).log('zindex', (zindex << 32), '<< 32', (feature << 36) | (zindex << 32) | color, 'whole');
                    setCurrent(matrix, (feature << 36) | (zindex << 32) | color);
                } else {
                    setCurrent(matrix, 0x0000000000);
                }
            }
        }

        // require(totalLength % groupWidth == 0, 'MTRX:SET:0');
        // require(totalLength / groupWidth == groupHeight, 'MTRX:SET:1');

        matrix.width = uint8(groupWidth);
        // // matrix.height = uint8(totalLength / groupWidth);

        resetIterator(matrix);
    }

    function addRowsAt(
        Types.Matrix memory matrix, /// cowboy hat
        uint8 index,
        uint8 amount
    ) internal pure {
        // require(index < matrix.data[0].length, 'MAT:ACA:0');
        for (uint256 i = 0; i < matrix.height; i++) {
            for (uint256 j = matrix.height; j > index; j--) {
                if (j < index) break;
                matrix.version.setBigMatrixPixelAt(i, j + amount, matrix.version.getBigMatrixPixelAt(i, j));
            }
            // "<=" is because this loop needs to run [amount] times
            for (uint256 j = index + 1; j <= index + amount; j++) {
                matrix.version.setBigMatrixPixelAt(i, j, matrix.version.getBigMatrixPixelAt(i, index));
            }
        }
        matrix.height += amount;
    }

    function addColumnsAt(
        Types.Matrix memory matrix, /// cowboy hat
        uint8 index,
        uint8 amount
    ) internal pure {
        // require(index < matrix.data[0].length, 'MAT:ACA:0');
        for (uint256 i = 0; i < matrix.width; i++) {
            for (uint256 j = matrix.width; j > index; j--) {
                if (j < index) break;
                matrix.version.setBigMatrixPixelAt(j + amount, i, matrix.version.getBigMatrixPixelAt(j, i));
            }
            // "<=" is because this loop needs to run [amount] times
            for (uint256 j = index + 1; j <= index + amount; j++) {
                matrix.version.setBigMatrixPixelAt(j, i, matrix.version.getBigMatrixPixelAt(index, i));
            }
        }
        matrix.width += amount;
    }
}