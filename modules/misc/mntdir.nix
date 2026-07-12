{
  modules.mntdir.nixos = {
    systemd.tmpfiles.rules = [
      "d /mnt 0755 root root - -"
    ];
  };
}
