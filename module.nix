{ localFlake, withSystem }:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.godot;
in
{
  options.services.godot = {
    enable = mkEnableOption "godot";
    package = mkOption {
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
