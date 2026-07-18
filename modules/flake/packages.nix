{
  config,
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
    listToAttrs
    nameValuePair
    ;

  inherit (lib.filesystem) listFilesRecursive;

  packagePaths = listFilesRecursive (paths.root "packages") |> filter (hasSuffix ".nix");

  mkPackage =
    path: pkgs:
    let
      package = pkgs.callPackage path;
    in
    nameValuePair (getName package) package;

  packages = packagePaths |> map (path: eachSystem config.systems (mkPackage path)) |> listToAttrs;
in
{
  top-level = { inherit packages; };
}
