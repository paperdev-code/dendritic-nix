{ inputs, ... }:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;

  # nixSource = fetchTarball {
  #  url = "https://github.com/NixOS/nix/archive/refs/tags/2.35.4.tar.gz";
  #  sha256 = "sha256:03h0j2bk97xgm15x02ccph4h1rwwci37mkdy6d1200jxzf51b2a4";
  # };

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
