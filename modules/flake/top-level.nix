{ lib, ... }:
let
  inherit (lib) mkOption types;

  topLevelModule = { ... }: {
    options = { };
  };
in
{
  options.topLevel = mkOption {
    description = "The flake attributes from the schema.";
    type = types.submodule topLevelModule;
  };
}
