mod components {
    mod erc2981 {
        mod interface;
        mod module;
    }
}

mod presets {
    mod erc721_royalty;
}

#[cfg(test)]
mod tests {
    mod test_erc721_royalty;
}
