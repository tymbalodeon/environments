if ("rust-toolchain.toml" | path type) != file {
  rm --force rust-toolchain.toml

  rust-toolchain-file
  | save rust-toolchain.toml
}
