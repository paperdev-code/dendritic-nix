{
  modules.proton.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      proton-vpn
      proton-pass
      protonmail-desktop
    ];

    persistence.directories = [
      # todo
    ];
  };
}
