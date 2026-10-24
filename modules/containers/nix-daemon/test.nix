{ config, inputs, ... }:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  topLevel.checks = eachSystem (
    pkgs:
    let
      nixImage =
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nix-daemon-image.passthru.baseImage;
    in
    {
      nix-daemon-podman = pkgs.testers.nixosTest {
        name = "nix-daemon-podman";

        nodes.machine = {
          imports = [ config.modules.nix-daemon-container.nixos ];
          virtualisation.oci-containers.backend = "podman";
          virtualisation.diskSize = 8192; # hit out-of-space
          environment.systemPackages = [ pkgs.podman ];
        };

        testScript = ''
          machine.start();

          machine.wait_for_unit("podman-nix-daemon.service")

          machine.succeed("podman load -i ${nixImage}")

          machine.succeed(
            "podman run --rm "
            "--volume nix-daemon-socket:/nix-daemon-socket "
            "nix:latest "
            "/nix/var/nix/profiles/default/bin/nix "
            "--extra-experimental-features nix-command "
            "--store unix:/nix-daemon-socket/socket "
            "store info"
          )
        '';
      };
    }
  );
}
