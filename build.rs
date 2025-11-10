fn main() {
    let arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    println!("cargo:rustc-link-arg=-Tsrc/arch/{}/linker.ld", arch);
    println!("cargo:rerun-if-changed=src/arch/{}/linker.ld", arch);
}
