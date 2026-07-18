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
  config._module.args.eachSystem = fn: genAttrs config.systems (system: fn (nixpkgsFor system));
}
