%lang starknet

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from erc2981.library import ERC2981

const RECEIVER = 0x123;
const FEE_NUMERATOR = 1;
const FEE_DENOMINATOR = 100;

const SALE_PRICE = 1000000;

const NEW_RECEIVER = 0x456;
const NEW_FEE_NUMERATOR = 2;
const NEW_FEE_DENOMINATOR = 101;

@external
func test_default_royalty{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    ERC2981.initializer(
        receiver=RECEIVER, fee_numerator=FEE_NUMERATOR, fee_denominator=FEE_DENOMINATOR
    );

    let zero = Uint256(low=0, high=0);
    let sale_price = Uint256(low=SALE_PRICE, high=0);

    let (receiver, royalty_amount) = ERC2981.royalty_info(token_id=zero, sale_price=sale_price);

    tempvar expected_royalty_amount;
    %{ ids.expected_royalty_amount = int(ids.SALE_PRICE * ids.FEE_NUMERATOR / ids.FEE_DENOMINATOR) %}
    assert royalty_amount.low = expected_royalty_amount;
    assert royalty_amount.high = 0;

    return ();
}

@external
func test_set_default_royalty{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    ERC2981.initializer(
        receiver=RECEIVER, fee_numerator=FEE_NUMERATOR, fee_denominator=FEE_DENOMINATOR
    );

    ERC2981.set_default_royalty(
        receiver=NEW_RECEIVER, fee_numerator=NEW_FEE_NUMERATOR, fee_denominator=NEW_FEE_DENOMINATOR
    );

    let zero = Uint256(low=0, high=0);
    let sale_price = Uint256(low=SALE_PRICE, high=0);

    let (receiver, royalty_amount) = ERC2981.royalty_info(token_id=zero, sale_price=sale_price);

    tempvar expected_royalty_amount;
    %{ ids.expected_royalty_amount = int(ids.SALE_PRICE * ids.NEW_FEE_NUMERATOR / ids.NEW_FEE_DENOMINATOR) %}
    assert royalty_amount.low = expected_royalty_amount;
    assert royalty_amount.high = 0;

    return ();
}
