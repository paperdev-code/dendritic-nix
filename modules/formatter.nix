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

  treefmtPkg =
    pkgs:
    pkgs.treefmt.withConfig {
      settings = {
        tree-root-file = "flake.nix";

        formatter.nix = mkFormatter pkgs.nixfmt {
          includes = "*.nix";
        };
      };
    };
in
{
  topLevel.formatter = eachSystem treefmtPkg;

  topLevel.checks = eachSystem (pkgs: {
    formatting =
      pkgs.runCommandLocal "treefmt-check"
        {
          buildInputs = [ (treefmtPkg pkgs) ];
        }
        ''
          set -e
          export HOME=$TMPDIR
          SRC=$TMP/src
          cp -r ${inputs.self} $SRC
          chmod -R a+w $SRC
          cd $SRC
          treefmt --fail-on-change
          touch $out
        '';
  });
}
