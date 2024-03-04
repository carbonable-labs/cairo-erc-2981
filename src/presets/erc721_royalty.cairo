#[starknet::contract]
mod ERC721Royalty {
    // Starknet deps
    use starknet::{get_caller_address, ContractAddress};

    // External deps
    use openzeppelin::access::ownable::interface::IOwnable;
    use openzeppelin::access::ownable::ownable::Ownable;
    use openzeppelin::introspection::interface::{ISRC5, ISRC5Camel};
    use openzeppelin::introspection::src5::SRC5;
    use openzeppelin::token::erc721::interface::{IERC721, IERC721CamelOnly};
    use openzeppelin::token::erc721::erc721::ERC721;

    // Local deps
    use cairo_erc_2981::components::erc2981::interface::{IERC2981, IERC2981Camel};
    use cairo_erc_2981::components::erc2981::module::ERC2981;

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        receiver: ContractAddress,
        fee_numerator: u256,
        fee_denominator: u256,
        owner: ContractAddress
    ) {
        self.initializer(name, symbol, receiver, fee_numerator, fee_denominator, owner);
    }

    // Access control

    #[external(v0)]
    impl OwnableImpl of IOwnable<ContractState> {
        fn owner(self: @ContractState) -> ContractAddress {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::owner(@unsafe_state)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::transfer_ownership(ref unsafe_state, new_owner)
        }

        fn renounce_ownership(ref self: ContractState) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::renounce_ownership(ref unsafe_state)
        }
    }

    // SRC5

    #[external(v0)]
    impl SRC5Impl of ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            let unsafe_state = SRC5::unsafe_new_contract_state();
            SRC5::SRC5Impl::supports_interface(@unsafe_state, interface_id)
        }
    }

    #[external(v0)]
    impl SRC5CamelImpl of ISRC5Camel<ContractState> {
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            self.supports_interface(interfaceId)
        }
    }

    // ERC721

    #[external(v0)]
    impl ERC721Impl of IERC721<ContractState> {
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::balance_of(@unsafe_state, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::owner_of(@unsafe_state, token_id)
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::get_approved(@unsafe_state, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::is_approved_for_all(@unsafe_state, owner, operator)
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::safe_transfer_from(ref unsafe_state, from, to, token_id, data)
        }
    }

    #[external(v0)]
    impl ERC721CamelImpl of IERC721CamelOnly<ContractState> {
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self.balance_of(account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            self.owner_of(tokenId)
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            self.transfer_from(from, to, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            self.safe_transfer_from(from, to, tokenId, data)
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            self.set_approval_for_all(operator, approved)
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            self.get_approved(tokenId)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            self.is_approved_for_all(owner, operator)
        }
    }

    // ERC2981

    #[external(v0)]
    impl ERC2981Impl of IERC2981<ContractState> {
        fn default_royalty(self: @ContractState) -> (ContractAddress, u256, u256) {
            let unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::ERC2981Impl::default_royalty(@unsafe_state)
        }

        fn token_royalty(self: @ContractState, token_id: u256) -> (ContractAddress, u256, u256) {
            let unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::ERC2981Impl::token_royalty(@unsafe_state, token_id)
        }

        fn royalty_info(
            self: @ContractState, token_id: u256, sale_price: u256
        ) -> (ContractAddress, u256) {
            let unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::ERC2981Impl::royalty_info(@unsafe_state, token_id, sale_price)
        }

        fn set_default_royalty(
            ref self: ContractState,
            receiver: ContractAddress,
            fee_numerator: u256,
            fee_denominator: u256
        ) {
            // [Check] Only owner
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);
            // [Effect] Set default royalty
            let mut unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::ERC2981Impl::set_default_royalty(
                ref unsafe_state, receiver, fee_numerator, fee_denominator
            )
        }

        fn set_token_royalty(
            ref self: ContractState,
            token_id: u256,
            receiver: ContractAddress,
            fee_numerator: u256,
            fee_denominator: u256
        ) {
            // [Check] Only owner
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);
            // [Effect] Set token royalty
            let mut unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::ERC2981Impl::set_token_royalty(
                ref unsafe_state, token_id, receiver, fee_numerator, fee_denominator
            )
        }
    }

    #[external(v0)]
    impl ERC2981CamelImpl of IERC2981Camel<ContractState> {
        fn defaultRoyalty(self: @ContractState) -> (ContractAddress, u256, u256) {
            self.default_royalty()
        }

        fn tokenRoyalty(self: @ContractState, tokenId: u256) -> (ContractAddress, u256, u256) {
            self.token_royalty(tokenId)
        }

        fn royaltyInfo(
            self: @ContractState, tokenId: u256, salePrice: u256
        ) -> (ContractAddress, u256) {
            self.royalty_info(tokenId, salePrice)
        }

        fn setDefaultRoyalty(
            ref self: ContractState,
            receiver: ContractAddress,
            feeNumerator: u256,
            feeDenominator: u256
        ) {
            self.set_default_royalty(receiver, feeNumerator, feeDenominator)
        }

        fn setTokenRoyalty(
            ref self: ContractState,
            tokenId: u256,
            receiver: ContractAddress,
            feeNumerator: u256,
            feeDenominator: u256
        ) {
            self.set_token_royalty(tokenId, receiver, feeNumerator, feeDenominator)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn initializer(
            ref self: ContractState,
            name: felt252,
            symbol: felt252,
            receiver: ContractAddress,
            fee_numerator: u256,
            fee_denominator: u256,
            owner: ContractAddress
        ) {
            // ERC721
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::InternalImpl::initializer(ref unsafe_state, name, symbol);
            // ERC2981
            let mut unsafe_state = ERC2981::unsafe_new_contract_state();
            ERC2981::InternalImpl::initializer(
                ref unsafe_state, receiver, fee_numerator, fee_denominator
            );
            // Access control
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::initializer(ref unsafe_state, owner);
        }
    }
}
