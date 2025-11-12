// Build script for CRUST-y Rust library
// Configures CXX code generation for C++/Rust FFI bridge

fn main() {
    // Configure CXX bridge code generation
    cxx_build::bridge("src/lib.rs")
        .flag_if_supported("-std=c++17")  // Use C++17 standard
        .flag_if_supported("-Wall")       // Enable all warnings
        .flag_if_supported("-Wextra")     // Enable extra warnings
        .compile("crustyV2");

    // Tell Cargo to rerun this build script if lib.rs changes
    println!("cargo:rerun-if-changed=src/lib.rs");

    // Tell Cargo to rerun if any Rust source files change
    println!("cargo:rerun-if-changed=src/control_handler.rs");
    println!("cargo:rerun-if-changed=src/status_handler.rs");
}
