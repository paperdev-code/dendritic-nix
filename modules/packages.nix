{
  inputs,
  paths,
  lib,
  ...
}:
let
  inherit (lib) getName mkMerge;
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
  packagePaths = inputs.self.lib.dendritic.listNixFilesRecursive (paths.root "packages");
in
{
  topLevel.packages = eachSystem (
    pkgs:
    packagePaths
    |> map (path: pkgs.callPackage path { })
    |> map (package: {
      ${getName package} = package;
    })
    |> mkMerge
  );
}
