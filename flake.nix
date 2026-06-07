{
  description = "CDUMM nix flake";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        let
          cdumm-native = pkgs.python3Packages.callPackage ./native { };
          privatebin = pkgs.python3Packages.callPackage ./nix/privatebin { };
          pyside6-fluent-widgets = pkgs.python3Packages.callPackage ./nix/pyside6-fluent-widgets {
            inherit pysidesix-frameless-window;
          };
          pysidesix-frameless-window = pkgs.python3Packages.callPackage ./nix/pysidesix-frameless-window { };

          crimsondesert-ultimatemodsmanager = pkgs.callPackage ./. {
            inherit cdumm-native privatebin pyside6-fluent-widgets;
          };
        in
        {
          packages.default = crimsondesert-ultimatemodsmanager;
          devShells.default = pkgs.mkShell {
            packages = [
              cdumm-native
              privatebin
              pyside6-fluent-widgets
            ]
            ++ (with pkgs.python3Packages; [
              bsdiff4
              cryptography
              lxml
              lz4
              psutil
              py7zr
              pyside6
              websocket-client
              xxhash
            ]);
          };
        };
    };
}
