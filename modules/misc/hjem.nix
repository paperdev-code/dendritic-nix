{ inputs, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    mkOption
    types
    ;

  nixosLoadEnvModule =
    this@{ hjem-lib, ... }:
    {
      files.".config/environment.d/50-hjem-env.conf".text =
        let
          format = value: if value != null then "\"${hjem-lib.toEnv value}\"" else "\"\"";
        in
        this.config.environment.sessionVariables
        |> mapAttrsToList (name: value: "${name}=${format value}")
        |> concatStringsSep "\n";
    };
in
{
  modules.hjem.nixos = _: {
    imports = [ inputs.hjem.nixosModules.default ];
    hjem.clobberByDefault = true;

    hjem.extraModules = [
      nixosLoadEnvModule
    ];
  };

  modules.stubs.nixos = _: {
    options.hjem = mkOption {
      type = types.submodule {
        freeformType = types.attrs;
      };
    };
  };
}
