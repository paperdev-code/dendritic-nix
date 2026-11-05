{ inputs, ... }:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
  nixDocker = "${inputs.nix}/docker.nix";
in
{
  topLevel.packages = eachSystem (
    pkgs:
    let
      nixImage = import nixDocker { inherit pkgs; };
    in
    {
      nix-daemon-image =
        pkgs.dockerTools.buildImage {
          name = "nix-daemon";
          tag = "latest";
          fromImage = import nixDocker { inherit pkgs; };
          config = {
            EntryPoint = [ "/nix/var/nix/profiles/default/bin/nix-daemon" ];
            Cmd = [ "--daemon" ];
            Volumes."/nix" = { };
          };
        }
        // {
          passthru.baseImage = nixImage;
        };
    }
  );
}
