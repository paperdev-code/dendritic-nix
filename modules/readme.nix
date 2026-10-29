{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkOrder types;

  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  options.readme = mkOption {
    type = types.lines;
    default = "";
  };

  options.chapters = mkOption {
    type = with types; attrsOf int;
    default = inputs.self.lib.utils.enumerate 100 [
      "intro"
      "hosts"
    ];
    readOnly = true;
  };

  config = {
    readme = mkOrder config.chapters.intro ''
      # Dendritic Nix

      :construction:
    '';

    topLevel = {
      packages = eachSystem (pkgs: {
        readme = pkgs.writeTextFile {
          name = "README.md";
          text = config.readme;

          checkPhase = ''
            formatted="$TMPDIR/result"
            cp "$out" "$formatted"
            ${pkgs.mdformat}/bin/mdformat "$formatted"
            ${pkgs.git}/bin/git --no-pager diff --no-index --color=auto -- "$out" "$TMPDIR/result"
          '';
        };
      });

      checks = eachSystem (pkgs: {
        readme-diff = pkgs.runCommand "readme-diff" { } ''
          generated=${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.readme}
          current=${../README.md}
          ${pkgs.git}/bin/git --no-pager diff --no-index --color=auto -- "$generated" "$current"
          touch $out
        '';
      });
    };
  };
}
