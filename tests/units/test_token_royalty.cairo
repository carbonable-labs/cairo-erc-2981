%lang starknet

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from src.erc2981.library import ERC2981

const RECEIVER = 0x123;
const FEE_NUMERATOR = 1;
const FEE_DENOMINATOR = 100;

const SALE_PRICE = 1000000;

const TOKEN_RECEIVER = 0x456;
const TOKEN_NUMERATOR = 2;
const TOKEN_DENOMINATOR = 101;

@external
func test_default_royalty{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    let zero = Uint256(low=0, high=0);
    let one = Uint256(low=1, high=0);
    let sale_price = Uint256(low=SALE_PRICE, high=0);

    ERC2981.initializer(
        receiver=RECEIVER, fee_numerator=FEE_NUMERATOR, fee_denominator=FEE_DENOMINATOR
    );

    ERC2981.set_token_royalty(
        token_id=zero,
        receiver=TOKEN_RECEIVER,
        fee_numerator=TOKEN_NUMERATOR,
        fee_denominator=TOKEN_DENOMINATOR,
    );

    let (receiver, royalty_amount) = ERC2981.royalty_info(token_id=zero, sale_price=sale_price);
    assert receiver = TOKEN_RECEIVER;
    tempvar expected_token_royalty_amount;
    %{ ids.expected_token_royalty_amount = int(ids.SALE_PRICE * ids.TOKEN_NUMERATOR / ids.TOKEN_DENOMINATOR) %}
    assert royalty_amount.low = expected_token_royalty_amount;
    assert royalty_amount.high = 0;

    let (receiver, royalty_amount) = ERC2981.royalty_info(token_id=one, sale_price=sale_price);
    assert receiver = RECEIVER;
    tempvar expected_default_royalty_amount;
    %{ ids.expected_default_royalty_amount = int(ids.SALE_PRICE * ids.FEE_NUMERATOR / ids.FEE_DENOMINATOR) %}
    assert royalty_amount.low = expected_default_royalty_amount;
    assert royalty_amount.high = 0;

    return ();
}
