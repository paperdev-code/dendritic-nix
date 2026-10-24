{ lib, ... }:
let
  inherit (lib) mkOption types;

  topLevelModule = { ... }: {
    options = {
      checks = mkOption {
        type = with types; lazyAttrsOf (attrsOf package);
      };

      devShells = mkOption {
        type = with types; lazyAttrsOf package;
      };

      formatter = mkOption {
        type = with types; lazyAttrsOf package;
      };

      lib = mkOption {
        type = types.attrs;
      };

      nixosConfigurations = mkOption {
        type = with types; attrsOf attrs;
      };

      nixosModules = mkOption {
        type = with types; attrsOf deferredModule;
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
  freeformType = with types; attrsOf anything;

  options.topLevel = mkOption {
    description = "The flake attributes from the schema.";
    type = types.submodule topLevelModule;
  };
}
