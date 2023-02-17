// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.uint256 import Uint256, uint256_check, uint256_mul_div_mod

from openzeppelin.introspection.erc165.library import ERC165

from src.utils.constants.library import IERC2981_ID

@storage_var
func ERC2981_receiver_() -> (receiver: felt) {
}

@storage_var
func ERC2981_token_receiver_(token_id: Uint256) -> (receiver: felt) {
}

@storage_var
func ERC2981_fee_numerator_() -> (fee_numerator: felt) {
}

@storage_var
func ERC2981_token_fee_numerator_(token_id: Uint256) -> (fee_numerator: felt) {
}

@storage_var
func ERC2981_fee_denominator_() -> (fee_denominator: felt) {
}

@storage_var
func ERC2981_token_fee_denominator_(token_id: Uint256) -> (fee_denominator: felt) {
}

// / @title ERC2981 implementation.
// / @notice This file contains functions related to the ERC2981 implementation.
// / @author @bal7hazar
// / @custom:namespace ERC2981
namespace ERC2981 {
    // @notice Initialize the ERC2981 implementation.
    // @dev Since float number can not be handled, the rate is managed by a numerator and a denominator.
    //      It fails if fee_denominator < 0 or fee_numerator > fee_denominator.
    //      It fails if receiver is the null address.
    // @param receiver The default royalty receiver address.
    // @param fee_numerator The default royalty rate numerator.
    // @param fee_denominator The default royalty rate denominator.
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        receiver: felt, fee_numerator: felt, fee_denominator: felt
    ) {
        ERC2981.set_default_royalty(receiver, fee_numerator, fee_denominator);
        ERC165.register_interface(IERC2981_ID);
        return ();
    }

    // @notice Get the default royalty.
    // @return receiver The royalty receiver address.
    // @return fee_numerator The royalty rate numerator.
    // @return fee_denominator The royalty rate denominator.
    func default_royalty{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        receiver: felt, fee_numerator: felt, fee_denominator: felt
    ) {
        let (receiver) = ERC2981_receiver_.read();
        let (fee_numerator) = ERC2981_fee_numerator_.read();
        let (fee_denominator) = ERC2981_fee_denominator_.read();
        return (receiver=receiver, fee_numerator=fee_numerator, fee_denominator=fee_denominator);
    }

    // @notice Get the token royalty.
    // @param token_id The token identifier.
    // @return receiver The royalty receiver address.
    // @return fee_numerator The royalty rate numerator.
    // @return fee_denominator The royalty rate denominator.
    func token_royalty{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256
    ) -> (receiver: felt, fee_numerator: felt, fee_denominator: felt) {
        // [Check] Uint256 compliancy
        with_attr error_message("ERC2981: token_id is not a valid Uint256") {
            uint256_check(token_id);
        }

        let (receiver) = ERC2981_token_receiver_.read(token_id);
        let (fee_numerator) = ERC2981_token_fee_numerator_.read(token_id);
        let (fee_denominator) = ERC2981_token_fee_denominator_.read(token_id);
        return (receiver=receiver, fee_numerator=fee_numerator, fee_denominator=fee_denominator);
    }

    // @notice Set the default royalty rate.
    // @dev Since float number can not be handled, the rate is managed by a numerator and a denominator.
    //      It fails if receiver is the null address.
    //      It fails if fee_denominator < 0 or fee_numerator > fee_denominator.
    // @param receiver The royalty receiver address.
    // @param fee_numerator The royalty rate numerator.
    // @param fee_denominator The royalty rate denominator.
    func set_default_royalty{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        receiver: felt, fee_numerator: felt, fee_denominator: felt
    ) {
        // [Check] Receiver is not the null address
        let not_zero = is_not_zero(receiver);
        with_attr error_message("ERC2981: invalid receiver") {
            assert not_zero = TRUE;
        }

        // [Check] Royalty denominator is higher than 0
        let not_zero = is_not_zero(fee_denominator);
        with_attr error_message("ERC2981: royalty denominator must be not null") {
            assert not_zero = TRUE;
        }

        // [Check] Royalty rate is lower than or equal to 1
        let lower = is_le(fee_numerator, fee_denominator);
        with_attr error_message("ERC2981: royalty rate must be lower than or equal to 1") {
            assert lower = TRUE;
        }

        // [Effect] Store values
        ERC2981_receiver_.write(receiver);
        ERC2981_fee_numerator_.write(fee_numerator);
        ERC2981_fee_denominator_.write(fee_denominator);

        return ();
    }

    // @notice Set the token royalty rate.
    // @dev Since float number can not be handled, the rate is managed by a numerator and a denominator.
    //      It fails if receiver is the null address.
    //      It fails if fee_denominator < 0 or fee_numerator > fee_denominator.
    // @param token_id The token identifier.
    // @param receiver The royalty receiver address.
    // @param fee_numerator The royalty rate numerator.
    // @param fee_denominator The royalty rate denominator.
    func set_token_royalty{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256, receiver: felt, fee_numerator: felt, fee_denominator: felt
    ) {
        // [Check] Uint256 compliancy
        with_attr error_message("ERC2981: token_id is not a valid Uint256") {
            uint256_check(token_id);
        }

        // [Check] Receiver is not the null address
        let not_zero = is_not_zero(receiver);
        with_attr error_message("ERC2981: invalid receiver") {
            assert not_zero = TRUE;
        }

        // [Check] Royalty denominator is higher than 0
        let not_zero = is_not_zero(fee_denominator);
        with_attr error_message("ERC2981: royalty denominator must be not null") {
            assert not_zero = TRUE;
        }

        // [Check] Royalty rate is lower than or equal to 1
        let lower = is_le(fee_numerator, fee_denominator);
        with_attr error_message("ERC2981: royalty rate must be lower than or equal to 1") {
            assert lower = TRUE;
        }

        // [Effect] Store values
        ERC2981_token_receiver_.write(token_id, receiver);
        ERC2981_token_fee_numerator_.write(token_id, fee_numerator);
        ERC2981_token_fee_denominator_.write(token_id, fee_denominator);

        return ();
    }

    // @notice Return the royalty info with the specified token id and the sale price.
    // @dev Since royalty rate is lower than or equal to 1,
    //      royalty_amount is lower than or equal to sale_price,
    //      therefore quotient_high can be ignored.
    //      It fails if sale_price is not compliant with Uint256 rules.
    // @param token_id The token identifier.
    // @param sale_price The transaction price.
    // @return receiver The royalty receiver address.
    // @return royalty_amount The royalty amount.
    func royalty_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256, sale_price: Uint256
    ) -> (receiver: felt, royalty_amount: Uint256) {
        // [Check] Uint256 compliancy
        with_attr error_message("ERC2981: sale_price is not a valid Uint256") {
            uint256_check(sale_price);
        }

        let (receiver) = ERC2981_token_receiver_.read(token_id);
        if (receiver != 0) {
            return _token_royalty_info(token_id=token_id, sale_price=sale_price);
        }
        return _default_royalty_info(sale_price=sale_price);
    }

    func _default_royalty_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        sale_price: Uint256
    ) -> (receiver: felt, royalty_amount: Uint256) {
        alloc_locals;

        let (receiver, fee_numerator, fee_denominator) = default_royalty();
        let (royalty_amount) = _royalty_amount(
            sale_price=sale_price, fee_numerator=fee_numerator, fee_denominator=fee_denominator
        );
        return (receiver=receiver, royalty_amount=royalty_amount);
    }

    func _token_royalty_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256, sale_price: Uint256
    ) -> (receiver: felt, royalty_amount: Uint256) {
        alloc_locals;

        let (receiver, fee_numerator, fee_denominator) = token_royalty(token_id);
        let (royalty_amount) = _royalty_amount(
            sale_price=sale_price, fee_numerator=fee_numerator, fee_denominator=fee_denominator
        );
        return (receiver=receiver, royalty_amount=royalty_amount);
    }

    func _royalty_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        sale_price: Uint256, fee_numerator: felt, fee_denominator: felt
    ) -> (royalty_amount: Uint256) {
        alloc_locals;

        let (low, high) = split_felt(fee_numerator);
        let fee_numerator_u256 = Uint256(low=low, high=high);

        let (low, high) = split_felt(fee_denominator);
        let fee_denominator_u256 = Uint256(low=low, high=high);

        let (quotient_low, _, _) = uint256_mul_div_mod(
            fee_numerator_u256, sale_price, fee_denominator_u256
        );

        return (royalty_amount=quotient_low);
    }
}
