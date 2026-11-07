{
  modules.scheduler.nixos = { pkgs, ... }: {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    services.scx-loader = {
      enable = true;
      config.default_sched = "scx_lavd";
      config.default_mode = "Gaming";
    };
  };
}
