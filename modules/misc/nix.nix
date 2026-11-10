{ lib, ... }:
let
  settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    download-buffer-size = 524288000;

    trusted-public-keys = [
      "jorn:3jcOdKtlACrfurRr3XrKyqti//kGFOwopSmlF7vnjVI="
    ];
  };
in
{
  modules.nix.nixos = _: {
    nix.settings = settings;
  };

  modules.nix.hjem = _: {
    files.".config/nix/nix.conf".text = ''
      experimental-features = ${lib.concatStringsSep " " settings.experimental-features}
    '';
  };
}
