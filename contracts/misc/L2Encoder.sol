// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {SafeCast} from '../dependencies/openzeppelin/contracts/SafeCast.sol';
import {IPool} from '../interfaces/IPool.sol';
import {DataTypes} from '../protocol/libraries/types/DataTypes.sol';

contract L2Encoder {
  using SafeCast for uint256;
  IPool public immutable POOL;

  constructor(IPool pool) {
    POOL = pool;
  }

  function encodeSupplyParams(
    address asset,
    uint256 amount,
    uint16 referralCode
  ) external view returns (bytes32) {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount.toUint128();
    bytes32 res;

    assembly {
      res := add(assetId, add(shl(16, shortenedAmount), shl(144, referralCode)))
    }
    return res;
  }

  function encodeSupplyWithPermitParams(
    address asset,
    uint256 amount,
    uint16 referralCode,
    uint256 deadline,
    uint8 permitV,
    bytes32 permitR,
    bytes32 permitS
  )
    external
    view
    returns (
      bytes32,
      bytes32,
      bytes32
    )
  {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount.toUint128();
    uint32 shortenedDeadline = deadline.toUint32();

    bytes32 res;
    assembly {
      res := add(
        assetId,
        add(
          shl(16, shortenedAmount),
          add(shl(144, referralCode), add(shl(160, shortenedDeadline), shl(192, permitV)))
        )
      )
    }

    return (res, permitR, permitS);
  }

  function encodeWithdrawParams(address asset, uint256 amount) external view returns (bytes32) {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount == type(uint256).max ? type(uint128).max : amount.toUint128();

    bytes32 res;
    assembly {
      res := add(assetId, shl(16, shortenedAmount))
    }
    return res;
  }

  function encodeBorrowParams(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode
  ) external view returns (bytes32) {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount.toUint128();
    uint8 shortenedInterestRateMode = interestRateMode.toUint8();
    bytes32 res;
    assembly {
      res := add(
        assetId,
        add(
          shl(16, shortenedAmount),
          add(shl(144, shortenedInterestRateMode), shl(152, referralCode))
        )
      )
    }
    return res;
  }

  function encodeRepayParams(
    address asset,
    uint256 amount,
    uint256 interestRateMode
  ) external view returns (bytes32) {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount == type(uint256).max ? type(uint128).max : amount.toUint128();
    uint8 shortenedInterestRateMode = interestRateMode.toUint8();

    bytes32 res;
    assembly {
      res := add(assetId, add(shl(16, shortenedAmount), shl(144, shortenedInterestRateMode)))
    }
    return res;
  }

  function encodeRepayWithPermitParams(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint256 deadline,
    uint8 permitV,
    bytes32 permitR,
    bytes32 permitS
  )
    external
    view
    returns (
      bytes32,
      bytes32,
      bytes32
    )
  {
    DataTypes.ReserveData memory data = POOL.getReserveData(asset);

    uint16 assetId = data.id;
    uint128 shortenedAmount = amount == type(uint256).max ? type(uint128).max : amount.toUint128();
    uint8 shortenedInterestRateMode = interestRateMode.toUint8();
    uint32 shortenedDeadline = deadline.toUint32();

    bytes32 res;
    assembly {
      res := add(
        assetId,
        add(
          shl(16, shortenedAmount),
          add(
            shl(144, shortenedInterestRateMode),
            add(shl(152, shortenedDeadline), shl(184, permitV))
          )
        )
      )
    }
    return (res, permitR, permitS);
  }
}
