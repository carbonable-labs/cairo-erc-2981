%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from erc2981.library import ERC2981

const RECEIVER = 0x123;
const FEE_NUMERATOR = 1;
const FEE_DENOMINATOR = 100;

@external
func test_initialization{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    ERC2981.initializer(
        receiver=RECEIVER, fee_numerator=FEE_NUMERATOR, fee_denominator=FEE_DENOMINATOR
    );

    let (receiver, fee_numerator, fee_denominator) = ERC2981.default_royalty();

    assert receiver = RECEIVER;
    assert fee_numerator = FEE_NUMERATOR;
    assert fee_denominator = FEE_DENOMINATOR;

    return ();
}

@external
func test_initialization_revert_receiver{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    %{ expect_revert("TRANSACTION_FAILED", "ERC2981: invalid receiver") %}
    ERC2981.initializer(receiver=0, fee_numerator=FEE_NUMERATOR, fee_denominator=FEE_DENOMINATOR);

    return ();
}

@external
func test_initialization_revert_denominator{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    %{ expect_revert("TRANSACTION_FAILED", "ERC2981: royalty denominator must be not null") %}
    ERC2981.initializer(receiver=RECEIVER, fee_numerator=FEE_NUMERATOR, fee_denominator=0);

    return ();
}

@external
func test_initialization_revert_rate{
    syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*
}() {
    %{ expect_revert("TRANSACTION_FAILED", "ERC2981: royalty rate must be lower than or equal to 1") %}
    ERC2981.initializer(
        receiver=RECEIVER, fee_numerator=FEE_DENOMINATOR, fee_denominator=FEE_NUMERATOR
    );

    return ();
}
