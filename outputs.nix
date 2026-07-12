{ nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;
  inherit (lib) evalModules filter hasSuffix;
  inherit (lib.filesystem) listFilesRecursive;

  modules = listFilesRecursive ./modules |> filter (file: hasSuffix ".nix" file);

  result = evalModules {
    inherit modules;
    class = "flake";
    specialArgs = { inherit inputs; };
  };
in
result.config.topLevel
