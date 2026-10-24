{
  inputs,
  paths,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    genAttrs
    getName
    mkMerge
    ;
  allSystems = import inputs.systems;
  eachSystem = genAttrs allSystems;
  packagePaths = inputs.self.lib.dendritic.listNixFilesRecursive (paths.root "packages");

  toAttrs = map (package: {
    ${getName package} = package;
  });

  pkgs = genAttrs allSystems (system: inputs.nixpkgs.legacyPackages.${system});

  unfreePkgs = genAttrs allSystems (
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }
  );

  allPackages =
    pred: pkgs:
    packagePaths
    |> map (path: pkgs.callPackage path { })
    |> filter pred
    |> toAttrs
    |> mkMerge;

  isFree = package: package.meta.license.free or false;
  isUnfree = package: !(isFree package);
in
{
  topLevel.packages = eachSystem (system: allPackages isFree pkgs.${system});

  topLevel.unfreePackages = eachSystem (system: allPackages isUnfree unfreePkgs.${system});
}
