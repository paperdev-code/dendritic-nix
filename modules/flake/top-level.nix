{ lib, ... }:
let
  inherit (lib) mkOption types;

  appModule = {
    type = mkOption {
      type = types.str;
      default = "app";
    };

    program = types.path;
  };

  topLevelModule = _: {
    options = {
      apps = mkOption {
        type = with types; lazyAttrsOf (attrsOf (submodule appModule));
      };

      checks = mkOption {
        type = with types; lazyAttrsOf (attrsOf package);
      };

      devShells = mkOption {
        type = with types; lazyAttrsOf package;
      };

      formatter = mkOption {
        type = with types; lazyAttrsOf package;
      };

      hjemConfigurations = mkOption {
        type = with types; lazyAttrsOf (attrsOf package);
      };

      lib = mkOption {
        type = types.attrs;
      };

      nixosConfigurations = mkOption {
        type = with types; attrsOf attrs;
      };

      nixosModules = mkOption {
        type = types.attrs;
      };

      packages = mkOption {
        type = with types; lazyAttrsOf (attrsOf package);
      };

      unfreePackages = mkOption {
        type = with types; lazyAttrsOf (attrsOf package);
      };
    };
  };
in
{
  freeformType = types.attrs;

  options.topLevel = mkOption {
    description = "The flake attributes from the schema.";
    type = types.submodule topLevelModule;
  };
}
