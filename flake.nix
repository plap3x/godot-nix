{
  description = "Nix flake for Godot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=879bd460b3d3e8571354ce172128fbcbac1ed633";
    flake-parts.url = "github:hercules-ci/flake-parts?rev=758cf7296bee11f1706a574c77d072b8a7baa881";
    godot-45 = {
      url = "github:godotengine/godot/4.5";
      flake = false;
    };
    godot-cpp = {
      url = "github:godotengine/godot-cpp/godot-4.5-stable";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      godot-45,
      godot-cpp,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        self,
        withSystem,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
        flakeModules.default = importApply ./flake-module.nix { inherit withSystem; };
      in
      {
        imports = [
          flakeModules.default
        ];
        flake = {
          inherit flakeModules;
          nixosModules.default = importApply ./nixos-module.nix {
            localFlake = self;
            inherit withSystem;
          };
          nixosConfigurations.test = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              self.nixosModules.default
              {
                programs.godot = {
                  enable = true;
                  # precision = "double";
                };
              }
            ];
          };
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            config,
            pkgs,
            ...
          }:
          {
            apps = {
              default = {
                type = "app";
                program = config.packages.default;
                meta = {
                  changelog = "https://github.com/godotengine/godot/releases/tag/4.5";
                  description = "Free and Open Source 2D and 3D game engine";
                  homepage = "https://godotengine.org";
                  license = {
                    spdxId = "MIT";
                    fullName = "MIT License";
                  };
                  platforms = [
                    "x86_64-linux"
                    "aarch64-linux"
                    "i686-linux"
                  ];
                  mainProgram = "godot";
                };
              };
              godotDebug = {
                type = "app";
                program = config.packages.godotDebug;
                meta = config.apps.default.meta;
              };
            };

            packages = {
              default = pkgs.callPackage ./godot.nix {
                src = inputs.godot-45;
                # precision = "double";
              };
              godotDebug = pkgs.callPackage ./godot.nix {
                src = inputs.godot-45;
              };
            };

            devShells = {
              default = pkgs.mkShell {
                packages = [
                  config.packages.default
                ];
                env = { };
                shellHook = ''
                  echo "Godot `godot --version`"
                '';
              };
              debug = pkgs.mkShell {
                packages = [
                  config.packages.godotDebug
                ];
                env = { };
                shellHook = ''
                  echo "Godot `godot --version`"
                '';
              };
            };
          };
      }
    );
}
