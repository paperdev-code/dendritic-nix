{
  config,
  inputs,
  paths,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  modules.programs.umbriel.nixos =
    this:
    let
      configFile = "${this.config.networking.hostName}.toml";
    in
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      programs.umbriel.enable = true;

      hjem.extraModules = [
        config.modules.programs.umbriel.hjem
        {
          programs.umbriel.settings.include.files = [
            configFile
          ];

          files.".config/umbriel/${configFile}" = {
            source = paths.dotfile "umbriel/${configFile}";
            type = "copy";
          };
        }
      ];
    };

  modules.programs.umbriel.hjem =
    this@{ pkgs, ... }:
    {
      imports = [ inputs.umbriel.hjemModules.default ];

      programs.umbriel.package = null;

      files.".config/umbriel/config.toml" = {
        source = paths.dotfile "umbriel/config.toml";
        type = "copy";
      };

      files.".config/umbriel/generated.toml".source =
        (pkgs.formats.toml { }).generate "generated.toml"
          this.config.programs.umbriel.settings;
    };

  modules.stubs.hjem = _: {
    options.programs.umbriel.settings = mkOption {
      type = types.unspecified;
      default = { };
    };
  };
}
