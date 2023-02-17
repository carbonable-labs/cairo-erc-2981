// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IERC2981 {
    func defaultRoyalty() -> (receiver: felt, feeNumerator: felt, feeDenominator: felt) {
    }

    func tokenRoyalty(tokenId: Uint256) -> (
        receiver: felt, feeNumerator: felt, feeDenominator: felt
    ) {
    }
    func royaltyInfo(tokenId: Uint256, salePrice: Uint256) -> (
        receiver: felt, royaltyAmount: Uint256
    ) {
    }
    func setDefaultRoyalty(receiver: felt, feeNumerator: felt, feeDenominator: felt) {
    }

    func setTokenRoyalty(
        tokenId: Uint256, receiver: felt, feeNumerator: felt, feeDenominator: felt
    ) {
    }
}
