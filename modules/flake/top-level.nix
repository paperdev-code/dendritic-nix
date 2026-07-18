{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib) mkOption types genAttrs;

  mkSystemAttrsModule =
    optionParams:
    types.submodule {
      options = genAttrs config.systems (_: mkOption optionParams);
    };

  topLevelModule = {
    options = {
      checks = mkOption {
        type = mkSystemAttrsModule { type = types.unspecified; };
      };
      formatter = mkOption {
        type = mkSystemAttrsModule { type = types.package; };
      };
      nixosConfigurations = mkOption {
        type = with types; attrsOf types.raw;
      };
      packages = mkOption {
        type = mkSystemAttrsModule { type = types.package; };
      };
      _debug = mkOption {
        type = types.attrs;
      };
    };
  };
in
{
  options.topLevel = mkOption {
    type = types.submodule topLevelModule;
  };

  config.topLevel._debug = { inherit config options; };
}
