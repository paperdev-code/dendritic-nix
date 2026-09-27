{ lib, self }:
let
  importLib = path: import path { inherit lib self; };
in
{
  dendritic = importLib ./dendritic.nix;
}
