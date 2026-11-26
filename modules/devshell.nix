{
  inputs,
  ...
}:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  topLevel.devShells = eachSystem (pkgs: {
    default = pkgs.mkShellNoCC {
      packages = with pkgs; [
        just
        nix
      ];
    };
  });
}
