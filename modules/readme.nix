{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkBefore mkOption types;

  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  options.readme = mkOption {
    type = types.lines;
    default = "";
  };

  config.readme = mkBefore ''
    # Dendritic Nix

    :construction:

    (screenshot)
  '';

  config.topLevel.packages = eachSystem (pkgs: {
    readme = pkgs.writeTextFile {
      name = "README.md";
      text = config.readme;

      checkPhase = ''
        ${pkgs.mdformat}/bin/mdformat --check "$out"
      '';
    };
  });

  config.topLevel.checks = eachSystem (pkgs: {
    readme-diff =
      pkgs.runCommand "readme-diff"
        {
          nativeBuildInputs = [ pkgs.git ];
        }
        ''
          generated=${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.readme}
          current=${../README.md}
          git --no-pager diff --no-index --color=auto -- $generated $current
          touch $out
        '';
  });
}
