{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  config.inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  config.inputs.nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";

  options.nixpkgs = {
    allowUnfree = mkOption {
      type = types.bool;
    };
    overlays = mkOption {
      type = with types; functionTo (functionTo attrs);
      default = [ ];
    };
  };

  config.nixpkgs = {
    allowUnfree = true;
  };

  config._module.args.nixpkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = config.nixpkgs;
    };
}
