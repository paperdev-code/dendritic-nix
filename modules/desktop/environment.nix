{ lib, ... }:
let
  inherit (lib) concatStringsSep mapAttrsToList;
in
{
  modules.environment.hjem =
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
}
