localFlake:

{
  lib,
  config,
  self,
  inputs,
  ...
}:
{
  flake = {
    nixosModules.godot = config.nixosModules.default;
  };
  perSystem =
    { system, ... }:
    {
      packages.godot = localFlake.withSystem system ({ config, ... }: config.packages.default);
    };
}
