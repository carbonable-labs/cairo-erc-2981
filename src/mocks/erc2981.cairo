#[starknet::contract]
mod MockERC2981 {
    /// OZ deps
    use openzeppelin::{access::ownable::OwnableComponent, introspection::src5::SRC5Component,};

    // local deps
    use cairo_erc_2981::components::erc2981::ERC2981Component;

    component!(path: ERC2981Component, storage: erc2981, event: ERC2981Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC2981Impl = ERC2981Component::ERC2981<ContractState>;
    impl ERC2981InternalImpl = ERC2981Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc2981: ERC2981Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC2981Event: ERC2981Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }
}