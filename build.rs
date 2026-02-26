fn main() {
    println!("cargo:rerun-if-changed=boot/boot.s");

    cc::Build::new()
        .file("boot/boot.s")
        .flag("-m64")
        .compile("boot");
}
