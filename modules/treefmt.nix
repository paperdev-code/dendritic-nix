{
  config,
  inputs,
  lib,
  perSystem,
  ...
}:
let
  inherit (lib) mkForce mkOption types;

  treefmtEval = perSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs config.treefmt);
in
{
  _class = "flake";

  options.treefmt = mkOption {
    type = types.deferredModule;
  };

  config.treefmt = {
    projectRootFile = mkForce "flake.nix";
    programs.nixfmt.enable = true;
  };

  config.topLevel.formatter = perSystem (
    pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper
  );

  config.topLevel.checks = perSystem (pkgs: {
    formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check inputs.self;
  });
}
