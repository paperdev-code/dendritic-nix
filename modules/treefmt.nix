{
  config,
  inputs,
  lib,
  eachSystem,
  ...
}:
let
  inherit (lib) mkForce mkOption types;

  treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs config.treefmt);
in
{
  config.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  options.treefmt = mkOption {
    type = types.deferredModule;
  };

  config.treefmt = {
    projectRootFile = mkForce "flake.nix";
    programs.nixfmt.enable = true;
    programs.statix.enable = true;
    programs.taplo.enable = true;
  };

  config.topLevel.formatter = eachSystem (
    pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
  );

  config.topLevel.checks = eachSystem (pkgs: {
    formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check inputs.self;
  });
}
