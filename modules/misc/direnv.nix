{
  modules.direnv.nixos = _: {
    services.angrr = {
      enable = true;
      period = "14d";
    };

    programs.direnv = {
      enable = true;
      loadInNixShell = false;
    };
  };
}
