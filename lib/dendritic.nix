{
  lib,
  self ? null,
  ...
}:
let
  inherit (lib)
    evalModules
    filter
    hasSuffix
    isAttrs
    isList
    optionals
    ;
  inherit (lib.filesystem) listFilesRecursive;

  isNixFile = hasSuffix ".nix";
  listNixFilesRecursive = directory: filter isNixFile (listFilesRecursive directory);

  # A merged deferredModule is a wrapper with a list-valued `imports` attribute.
  isLeaf = value: isAttrs value && isList (value.imports or null);

  # To allow this flake to reuse this function, this subdirectory shouldn't be doubly included.
  # When accessed from the flake, as input for another flake, include it.
  topLevelModules = optionals (self != null) (listFilesRecursive ../modules/flake);
in
{
  inherit isLeaf listNixFilesRecursive;

  mkFlake =
    directory: inputs:
    let
      result = evalModules {
        modules = topLevelModules ++ (listNixFilesRecursive directory);
        class = "flake";
        specialArgs.inputs = inputs;
      };
    in
    result.config.topLevel;
}
