{
  modules.proton.hjem = { pkgs, ... }: {
    packages = with pkgs; [
      proton-vpn
      proton-pass
      proton-pass-cli
      protonmail-desktop
    ];

    environment.sessionVariables = {
      PROTON_PASS_LINUX_KEYRING = "dbus";
    };

    # [explainer](https://dewaldv.com/posts/2026-03-24-proton-pass-secret-service/)
    systemd.services.load-proton-pass-ssh-keys = {
      after = [
        "graphical-session.target"
        "gnome-keyring-daemon.service"
        "gcr-ssh-agent.service"
      ];

      wantedBy = [
        "graphical-session.target"
      ];

      script = "${pkgs.proton-pass-cli}/bin/pass-cli ssh-agent load";

      serviceConfig = {
        Type = "oneshot";
        Environment = [
          "PROTON_PASS_LINUX_KEYRING=dbus"
          "SSH_AUTH_SOCK=%t/gcr/ssh"
        ];
      };
    };

    persistence.directories = [
      ".local/share/proton-pass-cli/.session"
      ".config/Proton Pass/"
      ".config/Proton Mail"
    ];
  };
}
