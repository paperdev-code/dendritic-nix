{ lib, ... }:
let
  inherit (lib) mkOption types;

  topLevelModule = { ... }: {
    options = {
      lib = mkOption {
        type = types.attrs;
      };
    };
  };
in
{
  options.topLevel = mkOption {
    description = "The flake attributes from the schema.";
    type = types.submodule topLevelModule;
  };
}
