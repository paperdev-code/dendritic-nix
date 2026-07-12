{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    filter
    mapAttrs
    mkDefault
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;
in
{
  modules.persistence.any = {
    options.persistence = {
      directories = mkOption {
        type = with types; listOf unspecified;
      };
      files = mkOption {
        type = with types; listOf unspecified;
      };
    };
  };

  modules.persistence.nixos =
    this@{ pkgs, ... }:
    let
      cfg = this.config.persistence;
    in
    {
      imports = [
        inputs.preservation.nixosModules.default
        config.modules.persistence.any
      ];

      options.persistence = {
        persistentPath = mkOption { type = types.path; };
      };

      options.users.users = mkOption {
        type = types.attrsOf (
          types.submodule (
            thisUser@{ name, ... }: {
              config.hashedPasswordFile =
                mkIf thisUser.config.isNormalUser (mkDefault "${this.config.persistence.persistentPath}/passwd-${name}");
            }
          )
        );
      };

      config = {
        # user options
        hjem.extraModules = [ config.modules.persistence.hjem ];

        # preservation
        preservation.enable = true;
        preservation.preserveAt.${cfg.persistentPath} = mkMerge [
          {
            directories = [
              "/var/lib/systemd/coredump"
              "/var/lib/systemd/rfkill"
              "/var/lib/systemd/timers"
              "/var/log"
              {
                directory = "/var/lib/nixos";
                inInitrd = true;
              }
            ];
            files = [
              {
                configureParent = true;
                file = "/etc/machine-id";
                how = "symlink";
                inInitrd = true;
              }
              {
                file = "/var/lib/systemd/random-seed";
                how = "symlink";
                inInitrd = true;
              }
            ];
          }
          {
            inherit (cfg) directories files;
            users = this.config.hjem.users |> mapAttrs (_: cfg: cfg.persistence);
          }
        ];

        # machine-id
        systemd.services."systemd-machine-id-commit" = {
          unitConfig.ConditionPathIsMountPoint = [
            ""
            "${cfg.persistentPath}/etc/machine-id"
          ];
          serviceConfig.ExecStart = [
            ""
            "systemd-machine-id-setup --commit --root ${cfg.persistentPath}"
          ];
        };

        # password loss mitigation
        users.mutableUsers = mkForce false;

        system.activationScripts.initialPasswordFiles =
          let
            ensurePasswdFile = path: plaintext: ''
              if [ ! -e "${path}" ]; then
                mkdir -p "$(dirname "${path}")";
                ${pkgs.mkpasswd}/bin/mkpasswd -m yescrypt "${plaintext}" > "${path}";
                chmod 600 "${path}";
              fi
            '';
          in
          {
            deps = [ "users" ];
            text =
              attrValues this.config.users.users
              |> filter (user: user.isNormalUser && user.hashedPasswordFile != "")
              |> map (user: ensurePasswdFile user.hashedPasswordFile "welkom")
              |> concatStringsSep "\n";
          };
      };
    };

  modules.persistence.hjem = {
    imports = [ config.modules.persistence.any ];

    persistence.directories = [
      "Desktop"
      "Documents"
      "Downloads"
      "Music"
      "Pictures"
      "Projects"
      "Public"
      "Templates"
      "Videos"
    ];
  };

  modules.stubs.nixos = {
    imports = [ config.modules.persistence.any ];
  };
}
