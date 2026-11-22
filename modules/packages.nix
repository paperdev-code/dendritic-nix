{
  inputs,
  paths,
  lib,
  ...
}:
let
  inherit (lib)
    filter
    functionArgs
    genAttrs
    getName
    intersectAttrs
    mkMerge
    ;
  allSystems = import inputs.systems;
  eachSystem = genAttrs allSystems;
  packagePaths = inputs.self.lib.dendritic.listNixFilesRecursive (paths.root "packages");

  toAttrs = map (package: {
    ${getName package} = package;
  });

  pkgs = genAttrs allSystems (system: inputs.nixpkgs.legacyPackages.${system});

  unfreePkgs = eachSystem (
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }
  );

  packageInputOverrides = eachSystem (system: {
    jdk25_headless = inputs.nixpkgs-stable.legacyPackages.${system}.jdk25_headless;
  });

  callPackage =
    pkgs: path:
    let
      packageInputs = intersectAttrs (functionArgs (
        import path
      )) packageInputOverrides.${pkgs.stdenv.hostPlatform.system};
    in
    pkgs.callPackage path packageInputs;

  allPackages =
    pred: pkgs:
    packagePaths
    |> map (callPackage pkgs)
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
