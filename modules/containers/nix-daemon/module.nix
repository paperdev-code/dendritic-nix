{ inputs, ... }:
{
  modules.containers.nix-daemon.nixos = { pkgs, ... }: {
    virtualisation.oci-containers = {
      containers.nix-daemon = {
        image = "nix-daemon:latest";
        imageFile = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.nix-daemon-image;
        autoStart = true;
        volumes = [
          "nix-daemon-socket:/nix/var/nix/daemon-socket"
        ];
      };
    };
  };
}
