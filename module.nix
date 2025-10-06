{ localFlake, withSystem }:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.godot;
in
{
  options.programs.godot = {
    enable = mkEnableOption "godot";
    precision = mkOption {
      description = "Floating point precision";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (withSystem pkgs.system (
        { pkgs, ... }:
        pkgs.callPackage localFlake.packages.${pkgs.system}.default {
          precision = cfg.precision;
        }
      ))
    ];
  };
}
