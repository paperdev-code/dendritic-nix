{ lib, inputs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.systems = mkOption {
    type = with types; listOf str;
    readOnly = true;
  };

  config.systems = import inputs.systems;
}
