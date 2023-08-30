use starknet::ContractAddress;

const IERC2981_ID: felt252 = 0x2a55205a;

#[starknet::interface]
trait IERC2981<TContractState> {
    fn default_royalty(self: @TContractState) -> (ContractAddress, u256, u256);
    fn token_royalty(self: @TContractState, token_id: u256) -> (ContractAddress, u256, u256);
    fn royalty_info(
        self: @TContractState, token_id: u256, sale_price: u256
    ) -> (ContractAddress, u256);
    fn set_default_royalty(
        ref self: TContractState,
        receiver: ContractAddress,
        fee_numerator: u256,
        fee_denominator: u256
    );
    fn set_token_royalty(
        ref self: TContractState,
        token_id: u256,
        receiver: ContractAddress,
        fee_numerator: u256,
        fee_denominator: u256
    );
}

#[starknet::interface]
trait IERC2981Legacy<TContractState> {
    fn defaultRoyalty(self: @TContractState) -> (ContractAddress, u256, u256);
    fn tokenRoyalty(self: @TContractState, tokenId: u256) -> (ContractAddress, u256, u256);
    fn royaltyInfo(
        self: @TContractState, tokenId: u256, salePrice: u256
    ) -> (ContractAddress, u256);
    fn setDefaultRoyalty(
        ref self: TContractState,
        receiver: ContractAddress,
        feeNumerator: u256,
        feeDenominator: u256
    );
    fn setTokenRoyalty(
        ref self: TContractState,
        tokenId: u256,
        receiver: ContractAddress,
        feeNumerator: u256,
        feeDenominator: u256
    );
}
