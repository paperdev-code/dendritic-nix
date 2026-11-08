{ inputs, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    mkDefault
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

  modules.hjem-standalone.hjem =
    this@{ pkgs, ... }:
    {
      options.name = mkOption {
        type = types.str;
      };

      config = {
        packages = [
          inputs.hjem.packages.${pkgs.stdenv.hostPlatform.system}.hjem
        ];

        clobberFiles = mkDefault true;
        directory = mkDefault "/home/${this.config.name}";
        user = mkDefault this.config.name;
      };
    };
}
