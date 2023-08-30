#[cfg(test)]
mod Test {
    // Starknet deps

    use starknet::ContractAddress;
    use starknet::deploy_syscall;
    use starknet::testing::set_contract_address;

    // External deps

    use openzeppelin::account::account::Account;

    // Dispatchers

    use cairo_erc_2981::components::erc2981::interface::{
        IERC2981Dispatcher, IERC2981DispatcherTrait
    };

    // Contracts

    use cairo_erc_2981::presets::erc721_royalty::ERC721Royalty;

    // Constants

    const NAME: felt252 = 'NAME';
    const SYMBOL: felt252 = 'SYMBOL';
    const TOKEN_ID: u256 = 1;
    const FEE_NUMERATOR: u256 = 5;
    const FEE_DENOMINATOR: u256 = 100;
    const NEW_FEE_NUMERATOR: u256 = 10;
    const NEW_FEE_DENOMINATOR: u256 = 50;

    // Setup

    #[derive(Drop)]
    struct Signers {
        owner: ContractAddress,
        receiver: ContractAddress,
        new_receiver: ContractAddress,
    }

    #[derive(Drop)]
    struct Contracts {
        preset: ContractAddress,
    }

    fn deploy_account(public_key: felt252) -> ContractAddress {
        let mut calldata = array![public_key];
        let (address, _) = deploy_syscall(
            Account::TEST_CLASS_HASH.try_into().expect('Account declare failed'),
            0,
            calldata.span(),
            false
        )
            .expect('Account deploy failed');
        address
    }

    fn deploy_preset(receiver: ContractAddress, owner: ContractAddress) -> ContractAddress {
        let mut calldata = array![
            NAME,
            SYMBOL,
            receiver.into(),
            FEE_NUMERATOR.low.into(),
            FEE_NUMERATOR.high.into(),
            FEE_DENOMINATOR.low.into(),
            FEE_DENOMINATOR.high.into(),
            owner.into()
        ];
        let (address, _) = deploy_syscall(
            ERC721Royalty::TEST_CLASS_HASH.try_into().expect('Preset declare failed'),
            0,
            calldata.span(),
            false
        )
            .expect('Preset deploy failed');
        address
    }

    fn setup() -> (Signers, Contracts) {
        let signers = Signers {
            owner: deploy_account('OWNER'),
            receiver: deploy_account('RECEIVER'),
            new_receiver: deploy_account('TOKEN_RECEIVER')
        };
        let preset_address = deploy_preset(signers.receiver, signers.owner);
        (signers, Contracts { preset: preset_address })
    }

    // Tests

    #[test]
    #[available_gas(1_250_000)]
    fn test_initialization() {
        // [Setup]
        let (signers, contracts) = setup();
        let erc2981 = IERC2981Dispatcher { contract_address: contracts.preset };

        // [Assert] Provide minter rights to anyone
        let (receiver, fee_numerator, fee_denominator) = erc2981.default_royalty();
        assert(receiver == signers.receiver, 'Invalid receiver');
        assert(fee_numerator == FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_600_000)]
    fn test_set_default_royalty() {
        // [Setup]
        let (signers, contracts) = setup();
        let erc2981 = IERC2981Dispatcher { contract_address: contracts.preset };

        // [Effect] Set default royalty
        set_contract_address(signers.owner);
        erc2981.set_default_royalty(signers.new_receiver, NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR);

        // [Assert] Default royalty
        let (receiver, fee_numerator, fee_denominator) = erc2981.default_royalty();
        assert(receiver == signers.new_receiver, 'Invalid receiver');
        assert(fee_numerator == NEW_FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == NEW_FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_250_000)]
    #[should_panic]
    fn test_set_default_royalty_revert_not_owner() {
        // [Setup]
        let (signers, contracts) = setup();
        let erc2981 = IERC2981Dispatcher { contract_address: contracts.preset };

        // [Revert] Set default royalty
        set_contract_address(signers.new_receiver);
        erc2981.set_default_royalty(signers.new_receiver, NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR);
    }

    #[test]
    #[available_gas(1_600_000)]
    fn test_set_token_royalty() {
        // [Setup]
        let (signers, contracts) = setup();
        let erc2981 = IERC2981Dispatcher { contract_address: contracts.preset };

        // [Effect] Set default royalty
        set_contract_address(signers.owner);
        erc2981
            .set_token_royalty(
                TOKEN_ID, signers.new_receiver, NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );

        // [Assert] Token royalty
        let (receiver, fee_numerator, fee_denominator) = erc2981.token_royalty(TOKEN_ID);
        assert(receiver == signers.new_receiver, 'Invalid receiver');
        assert(fee_numerator == NEW_FEE_NUMERATOR.into(), 'Invalid fee numerator');
        assert(fee_denominator == NEW_FEE_DENOMINATOR.into(), 'Invalid fee denominator');
    }

    #[test]
    #[available_gas(1_250_000)]
    #[should_panic]
    fn test_set_token_royalty_revert_not_owner() {
        // [Setup]
        let (signers, contracts) = setup();
        let erc2981 = IERC2981Dispatcher { contract_address: contracts.preset };

        // [Revert] Set default royalty
        set_contract_address(signers.new_receiver);
        erc2981
            .set_token_royalty(
                TOKEN_ID, signers.new_receiver, NEW_FEE_NUMERATOR, NEW_FEE_DENOMINATOR
            );
    }
}
