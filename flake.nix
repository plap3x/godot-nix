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
      in
      {
        imports = [ ];
        flake.nixosModules.default = importApply ./module.nix {
          localFlake = self;
          inherit withSystem;
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          {
            devShells.default = pkgs.mkShell {
              packages = with pkgs; [

              ];
              env = { };
              shellHook = ''

              '';
            };
          };
      }
    );
}
