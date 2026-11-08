{ lib, inputs, ... }:
let
  inherit (lib)
    attrValues
    evalModules
    flatten
    filter
    ;

  hjemModules = map (subpath: "${inputs.hjem}/modules/${subpath}") [
    "common/user.nix"
    "nixos/systemd.nix"
  ];

  # [reference](https://github.com/feel-co/hjem/blob/main/modules/nixos/base.nix)
  mkOutput = cfg: {
    manifest = {
      version = 3;

      files =
        [
          cfg.files
          cfg.xdg.cache.files
          cfg.xdg.config.files
          cfg.xdg.data.files
          cfg.xdg.state.files
        ]
        |> map (set: attrValues set |> filter (file: file.enable))
        |> flatten;
    };

    packages = cfg.packages;
  };
in
{
  hjemHome =
    {
      modules,
      pkgs,
    }:
    let
      hjem-lib = inputs.hjem.hjem-lib.${pkgs.stdenv.hostPlatform.system};

      # minimal utils with subset of systemd related attributes
      utils = import "${inputs.nixpkgs}/nixos/lib/utils.nix" {
        inherit lib pkgs;
        config = {
          systemd = {
            globalEnvironment = { };
            defaultPath = [ ];
            enableStrictShellChecks = false;
          };
        };
      };
    in
    {
      class = "hjem";

      modules = flatten [
        hjemModules
        modules
      ];

      specialArgs = {
        inherit pkgs hjem-lib utils;
      };
    }
    |> evalModules
    |> (result: mkOutput result.config);
}
