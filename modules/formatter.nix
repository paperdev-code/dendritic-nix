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
    let
      treefmtPkg = pkgs.treefmt.withConfig {
        settings = {
          tree-root-file = "flake.nix";

          formatter.md = mkFormatter pkgs.mdformat {
            includes = "*.md";
          };

          formatter.nix = mkFormatter pkgs.nixfmt {
            includes = "*.nix";
          };

          formatter.toml = mkFormatter pkgs.taplo {
            options = [ "fmt" ];
            includes = "*.toml";
          };
        };
      };

      readme = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.readme;

      updateReadmePkg = pkgs.writeShellApplication {
        name = "update-readme";
        runtimeInputs = [
          pkgs.coreutils
        ];
        text = ''
          [[ -f README.md ]] || exit 0
          cmp -s "${readme}" README.md && exit 0
          cat "${readme}" > README.md
          echo "updated README.md"
        '';
      };
    in
    pkgs.writeShellApplication {
      name = "formatter";
      text = ''
        ${updateReadmePkg}/bin/update-readme
        ${treefmtPkg}/bin/treefmt
      '';
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
