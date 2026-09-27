inputs@{ nixpkgs, ... }:
let
  inherit (nixpkgs) lib;
  inherit (lib) evalModules filter hasSuffix;
  inherit (lib.filesystem) listFilesRecursive;

  isNixFile = hasSuffix ".nix";
  modules = filter isNixFile (listFilesRecursive ./modules);
in
(evalModules {
  inherit modules;
  class = "flake";
  specialArgs.inputs = inputs;
}).config.topLevel
