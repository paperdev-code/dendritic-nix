{ inputs, ... }:
{
  modules.rpcs3.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rpcs3 # nixpkgs version is old
      rusty-psn-gui
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.lsfg-vk # requires lossless scaling (from steam)
    ];

    persistence.directories = [
      ".config/rpcs3"
      ".config/lsfg-vk"
    ];
  };
}
