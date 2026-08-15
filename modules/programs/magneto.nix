{ inputs, ... }:
{
  modules.magneto.hjem = { pkgs, ... }: {
    packages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.magneto
    ];
  };
}
