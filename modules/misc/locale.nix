{ lib, ... }:
let
  inherit (lib) genAttrs;
in
{
  modules.locale.nixos = {
    time.timeZone = "Europe/Amsterdam";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = genAttrs [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_TELEPHONE"
        "LC_TIME"
      ] (_: "nl_NL.UTF-8");
    };
  };
}
