{
  description = "A bevy project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    nixpkgs,
    fenix,
    flake-utils,
    ...
  }: let
    name = "Rust / Bevy Engine";
    systems = [ "x86_64-linux" ];
    forAllSystems = func: (nixpkgs.lib.genAttrs systems func);
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [fenix.overlays.default];
      };
      lib = pkgs.lib;
    in {
      default = pkgs.mkShell rec {
        nativeBuildInputs = with pkgs; [
          pkg-config
          clang
          lld
        ];
        buildInputs = with pkgs;
          [
            # rust toolchain
            (pkgs.fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            rust-analyzer-nightly
            cargo-watch
          ]
          # https://github.com/bevyengine/bevy/blob/v0.16.1/docs/linux_dependencies.md#nix
          ++ (lib.optionals pkgs.stdenv.isLinux [
            udev
            alsa-lib
            vulkan-loader
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            libxkbcommon
            wayland
          ]);
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

        shellHook = ''
          export RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=lld"
          export WINIT_UNIX_BACKEND=wayland
          
          echo "env: 🚀 '${name}' 🚀 is ready!"
        '';
      };
    });
  };
}
