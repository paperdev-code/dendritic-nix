{
  modules.scheduler.nixos = { pkgs, ... }: {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };
}
