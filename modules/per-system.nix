{
  config,
  lib,
  nixpkgsFor,
  ...
}:
let
  inherit (lib) genAttrs;
in
{
  _class = "flake";

  config._module.args.perSystem = fn: genAttrs config.systems (system: fn (nixpkgsFor system));
}
