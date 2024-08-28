#[cfg(test)]
mod Test {
    // Core deps
    use core::serde::Serde;

    // Starknet-Foundry deps
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address, stop_cheat_caller_address
    };

    // Starknet deps
    use starknet::{ContractAddress, deploy_syscall};

    // Dispatchers
    use cairo_erc_2981::interfaces::erc2981::{IERC2981Dispatcher, IERC2981DispatcherTrait};

    // Contracts
    use cairo_erc_2981::presets::erc721_royalty::ERC721Royalty;

    // Constants
    const RECEIVER: felt252 = 'RECEIVER';
    const NEW_RECEIVER: felt252 = 'NEW_RECEIVER';
    const OWNER: felt252 = 'OWNER';
    const TOKEN_ID: u256 = 1;
    const FEE_NUMERATOR: u256 = 5;
    const FEE_DENOMINATOR: u256 = 100;
    const NEW_FEE_NUMERATOR: u256 = 10;
    const NEW_FEE_DENOMINATOR: u256 = 50;

    // Setup
    fn setup(receiver: ContractAddress, owner: ContractAddress) -> ContractAddress {
        let name: ByteArray = "NAME";
        let symbol: ByteArray = "SYMBOL";
        let base_uri: ByteArray = "ipfs://abcdefghi/";

        let mut calldata: Array<felt252> = array![];
        name.serialize(ref calldata);
        symbol.serialize(ref calldata);
        base_uri.serialize(ref calldata);
        receiver.serialize(ref calldata);
        FEE_NUMERATOR.low.serialize(ref calldata);
        FEE_NUMERATOR.high.serialize(ref calldata);
        FEE_DENOMINATOR.low.serialize(ref calldata);
        FEE_DENOMINATOR.high.serialize(ref calldata);
        owner.serialize(ref calldata);

        let contract = declare("ERC721Royalty").unwrap();
        let (contract_address, _) = contract.deploy(@calldata).unwrap();

        contract_address
    }

    // Tests
    #[test]
    #[available_gas(1_250_000)]
    fn test_initialization() {
        // [Setup]
        let preset_contract_address = setup(
            RECEIVER.try_into().unwrap(), OWNER.try_into().unwrap()
        );
        let preset = IERC2981Dispatcher { contract_address: preset_contract_address };

        // [Assert] Provide minter rights to anyone
        let (receiver, fee_numerator, fee_denominator) = preset.default_royalty();
        assert(receiver == RECEIVER.try_into().unwrap(), 'Invalid receiver');
        assert(fee_numerator == FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_600_000)]
    fn test_set_default_royalty() {
        // [Setup]
        let preset_contract_address = setup(
            RECEIVER.try_into().unwrap(), OWNER.try_into().unwrap()
        );
        let preset = IERC2981Dispatcher { contract_address: preset_contract_address };

        // [Effect] Set default royalty
        start_cheat_caller_address(preset_contract_address, OWNER.try_into().unwrap());
        preset
            .set_default_royalty(
                NEW_RECEIVER.try_into().unwrap(), NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );
        stop_cheat_caller_address(preset_contract_address);

        // [Assert] Default royalty
        let (receiver, fee_numerator, fee_denominator) = preset.default_royalty();
        assert(receiver == NEW_RECEIVER.try_into().unwrap(), 'Invalid receiver');
        assert(fee_numerator == NEW_FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == NEW_FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_250_000)]
    #[should_panic]
    fn test_set_default_royalty_revert_not_owner() {
        // [Setup]
        let preset_contract_address = setup(
            RECEIVER.try_into().unwrap(), OWNER.try_into().unwrap()
        );
        let preset = IERC2981Dispatcher { contract_address: preset_contract_address };

        // [Revert] Set default royalty
        start_cheat_caller_address(preset_contract_address, NEW_RECEIVER.try_into().unwrap());
        preset
            .set_default_royalty(
                NEW_RECEIVER.try_into().unwrap(), NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );
        stop_cheat_caller_address(preset_contract_address);
    }

    #[test]
    #[available_gas(1_600_000)]
    fn test_set_token_royalty() {
        // [Setup]
        let preset_contract_address = setup(
            RECEIVER.try_into().unwrap(), OWNER.try_into().unwrap()
        );
        let preset = IERC2981Dispatcher { contract_address: preset_contract_address };

        // [Effect] Set default royalty
        start_cheat_caller_address(preset_contract_address, OWNER.try_into().unwrap());
        preset
            .set_token_royalty(
                TOKEN_ID, NEW_RECEIVER.try_into().unwrap(), NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );
        stop_cheat_caller_address(preset_contract_address);

        // [Assert] Token royalty
        let (receiver, fee_numerator, fee_denominator) = preset.token_royalty(TOKEN_ID);
        assert(receiver == NEW_RECEIVER.try_into().unwrap(), 'Invalid receiver');
        assert(fee_numerator == NEW_FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == NEW_FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_250_000)]
    #[should_panic]
    fn test_set_token_royalty_revert_not_owner() {
        // [Setup]
        let preset_contract_address = setup(
            RECEIVER.try_into().unwrap(), OWNER.try_into().unwrap()
        );
        let preset = IERC2981Dispatcher { contract_address: preset_contract_address };

        // [Revert] Set default royalty
        start_cheat_caller_address(preset_contract_address, NEW_RECEIVER.try_into().unwrap());
        preset
            .set_token_royalty(
                TOKEN_ID, NEW_RECEIVER.try_into().unwrap(), NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );
        stop_cheat_caller_address(preset_contract_address);
    }
}
