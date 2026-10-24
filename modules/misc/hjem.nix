{ inputs, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  modules.hjem.nixos = _: {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem.clobberByDefault = true;
  };

  modules.stubs.nixos = _: {
    options.hjem = mkOption {
      type = types.submodule {
        freeformType = types.attrs;
      };
    };
  };
}
