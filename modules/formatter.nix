{
  inputs,
  lib,
  ...
}:
let
  mkFormatter =
    pkg: opts:
    opts
    // {
      command = "${lib.getBin pkg}/bin/${lib.getName pkg}";
    };

  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  topLevel.formatter = eachSystem (
    pkgs:
    pkgs.treefmt.withConfig {
      settings = {
        tree-root-file = "flake.nix";

        formatter.nix = mkFormatter pkgs.nixfmt {
          includes = "*.nix";
        };
      };
    }
  );
}
