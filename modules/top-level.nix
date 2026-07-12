{ config, lib, ... }:
let
  inherit (lib) mkOption types genAttrs;

  mkSystemAttrsModule =
    optionParams:
    types.submodule {
      options = genAttrs config.systems (_: mkOption optionParams);
    };

  topLevelModule = {
    options = {
      _debug = mkOption {
        type = types.attrs;
      };
    };
  };
in
{
  _class = "flake";

  options.topLevel = mkOption {
    type = types.submodule topLevelModule;
  };

  config.topLevel._debug = { inherit config; };
}
