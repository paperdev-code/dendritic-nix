{ lib, inputs, ... }:
let
  inherit (lib) mkOption types;
in
{
  config.inputs.systems.url = "github:nix-systems/x86_64-linux";

  options.systems = mkOption {
    type = with types; listOf str;
    readOnly = true;
  };

  config.systems = import inputs.systems;
}
