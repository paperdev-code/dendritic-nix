{
  eachSystem,
  lib,
  paths,
  ...
}:
let
  inherit (lib)
    filter
    getName
    hasSuffix
    mkMerge
    ;

  inherit (lib.filesystem) listFilesRecursive;

  packagePaths = listFilesRecursive (paths.root "packages") |> filter (hasSuffix ".nix");

  mkPackage =
    path: pkgs:
    let
      package = pkgs.callPackage path { };
    in
    {
      ${(getName package)} = package;
    };

  packages = packagePaths |> map (path: eachSystem (mkPackage path));
in
{
  topLevel.packages = mkMerge packages;
}
