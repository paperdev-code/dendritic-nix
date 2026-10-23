{ lib, ... }:
let
  inherit (lib) genAttrs;
in
{
  eachSystemWith =
    systems: packages: f:
    genAttrs systems (system: f packages.${system});
}
