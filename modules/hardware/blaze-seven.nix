{ ... }:
{
  # the unused FocalTech fingerprint reader (2808:c652), resets every few seconds,
  # deauthorize it to stop the USB churn.
  modules.hardware.blazeSeven.nixos = _: {
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2808", ATTR{idProduct}=="c652", ATTR{authorized}="0"
    '';
  };
}
