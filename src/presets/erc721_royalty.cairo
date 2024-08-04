#[starknet::contract]
mod ERC721Royalty {
    // Starknet deps
    use starknet::{get_caller_address, ContractAddress};

    // OZ deps
    use openzeppelin::{
        access::ownable::OwnableComponent, introspection::src5::SRC5Component,
        token::erc721::{ERC721Component, ERC721HooksEmptyImpl}
    };

    // Local deps
    use cairo_erc_2981::components::erc2981::ERC2981Component;
    use cairo_erc_2981::interfaces::erc2981::{IERC2981, IERC2981Camel};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: ERC2981Component, storage: erc2981, event: ERC2981Event);


    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    // ERC2981
    #[abi(embed_v0)]
    impl ERC2981Impl = ERC2981Component::ERC2981<ContractState>;
    impl ERC2981InternalImpl = ERC2981Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        erc2981: ERC2981Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        ERC2981Event: ERC2981Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
        receiver: ContractAddress,
        fee_numerator: u256,
        fee_denominator: u256,
        owner: ContractAddress
    ) {
        self.initializer(name, symbol, base_uri, receiver, fee_numerator, fee_denominator, owner);
    }

    #[abi(embed_v0)]
    impl ERC2981CamelImpl of IERC2981Camel<ContractState> {
        fn defaultRoyalty(self: @ContractState) -> (ContractAddress, u256, u256) {
            self.erc2981.default_royalty()
        }

        fn tokenRoyalty(self: @ContractState, tokenId: u256) -> (ContractAddress, u256, u256) {
            self.erc2981.token_royalty(tokenId)
        }

        fn royaltyInfo(
            self: @ContractState, tokenId: u256, salePrice: u256
        ) -> (ContractAddress, u256) {
            self.erc2981.royalty_info(tokenId, salePrice)
        }

        fn setDefaultRoyalty(
            ref self: ContractState,
            receiver: ContractAddress,
            feeNumerator: u256,
            feeDenominator: u256
        ) {
            self.erc2981.set_default_royalty(receiver, feeNumerator, feeDenominator)
        }

        fn setTokenRoyalty(
            ref self: ContractState,
            tokenId: u256,
            receiver: ContractAddress,
            feeNumerator: u256,
            feeDenominator: u256
        ) {
            self.erc2981.set_token_royalty(tokenId, receiver, feeNumerator, feeDenominator)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn initializer(
            ref self: ContractState,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
            receiver: ContractAddress,
            fee_numerator: u256,
            fee_denominator: u256,
            owner: ContractAddress
        ) {
            // ERC721
            self.erc721.initializer(name, symbol, base_uri);

            // ERC2981
            self.erc2981.initializer(receiver, fee_numerator, fee_denominator);

            // Access control
            self.ownable.initializer(owner);
        }
    }
}
