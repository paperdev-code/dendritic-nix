{ inputs, ... }:
{
  modules.scheduler.nixos = { pkgs, ... }: {
    services.ananicy = {
      enable = true;
      package = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };
}
