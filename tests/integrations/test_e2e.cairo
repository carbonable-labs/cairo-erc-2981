// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc721.IERC721 import IERC721
from src.erc2981.IERC2981 import IERC2981

const NAME = 'NAME';
const SYMBOL = 'SYMBOL';
const OWNER = 0x123;
const FEE_NUMERATOR = 1;
const FEE_DENOMINATOR = 100;
const ANYONE = 0x456;
const SALE_PRICE = 1000000;

@view
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    %{
        context.contract_address = deploy_contract(
            contract="./src/erc2981/presets/ERC721Royalty.cairo",
            constructor_args={
                "name": ids.NAME,
                "symbol": ids.SYMBOL,
                "receiver": ids.OWNER,
                "fee_numerator": ids.FEE_NUMERATOR,
                "fee_denominator": ids.FEE_DENOMINATOR,
                "owner": ids.OWNER,
            }
        ).contract_address
    %}

    return ();
}

@view
func test_initialization{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let zero = Uint256(low=0, high=0);
    let sale_price = Uint256(low=SALE_PRICE, high=0);

    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}

    let (receiver, royalty_amount) = IERC2981.royaltyInfo(
        contract_address=contract_address, tokenId=zero, salePrice=sale_price
    );
    tempvar expected_amount;
    %{ ids.expected_amount = int(ids.SALE_PRICE * ids.FEE_NUMERATOR / ids.FEE_DENOMINATOR) %}

    assert receiver = OWNER;
    assert royalty_amount.low = expected_amount;
    assert royalty_amount.high = 0;

    return ();
}

@view
func test_set_default_royalty_revert_not_owner{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}

    %{
        stop_prank = start_prank(caller_address=ids.ANYONE, target_contract_address=context.contract_address)
        expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner")
    %}
    IERC2981.setDefaultRoyalty(
        contract_address=contract_address,
        receiver=ANYONE,
        feeNumerator=FEE_NUMERATOR,
        feeDenominator=FEE_DENOMINATOR,
    );
    %{ stop_prank() %}

    return ();
}

@view
func test_set_token_royalty_revert_not_owner{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    tempvar contract_address;
    %{ ids.contract_address = context.contract_address %}
    let zero = Uint256(low=0, high=0);

    %{
        stop_prank = start_prank(caller_address=ids.ANYONE, target_contract_address=context.contract_address)
        expect_revert("TRANSACTION_FAILED", "Ownable: caller is not the owner")
    %}
    IERC2981.setTokenRoyalty(
        contract_address=contract_address,
        tokenId=zero,
        receiver=ANYONE,
        feeNumerator=FEE_NUMERATOR,
        feeDenominator=FEE_DENOMINATOR,
    );
    %{ stop_prank() %}

    return ();
}
