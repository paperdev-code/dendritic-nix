{
  modules.nix.nixos = _: {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      download-buffer-size = 524288000;
    };
  };
}
