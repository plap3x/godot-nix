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
    package = mkOption {
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);
    };
    precision = mkOption {
      description = "Floating point precision";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
