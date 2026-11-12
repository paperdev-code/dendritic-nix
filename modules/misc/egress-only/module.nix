{ lib, ... }:
let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    mkForce
    mkIf
    mkOption
    types
    ;

  namespace = "egress-only";
  hostAddress = "10.77.0.1";
  address = "10.77.0.2";

  unitName = "netns-${namespace}";
  # note: IFNAMSIZ is 16 bytes (including sentinel)
  hostVeth = "veth-egressonly";
  nsVeth = "eth-egressonly";
  nsPath = "/run/netns/${namespace}";
  nsArg = escapeShellArg namespace;

  # destinations the namespace may never reach; matched by the forward chain
  # and by the members' cgroup filter.
  blockedRanges = [
    "10.0.0.0/8"
    "100.64.0.0/10"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];
in
{
  modules.egress-only.nixos =
    this@{ pkgs, ... }:
    let
      cfg = this.config.services.egress-only;
      resolvConf = "/etc/egress-only/resolv.conf";
    in
    {
      options.services.egress-only.nameservers = mkOption {
        type = types.listOf types.str;
        default = [
          "9.9.9.9"
          "1.1.1.1"
        ];
      };

      options.systemd.services = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }:
            {
              options.egress-only = mkOption {
                type = types.bool;
                default = false;
              };

              config = mkIf config.egress-only {
                requires = [ "${unitName}.service" ];
                after = [ "${unitName}.service" ];

                serviceConfig = {
                  NetworkNamespacePath = mkForce nsPath;
                  # in case something happens with the firewall
                  # this will ensure it's still blocked (sort of)
                  IPAddressDeny = mkForce blockedRanges;
                  IPAddressAllow = mkForce [ ];

                  # their own nameservers, in case host's wouldn't be reachable.
                  BindReadOnlyPaths = [ "${resolvConf}:/etc/resolv.conf" ];
                };
              };
            }
          )
        );
      };

      config = {
        assertions = [
          {
            assertion = this.config.networking.nftables.enable;
            message = ''
              systemd.services.<name>.egress-only requires networking.nftables.enable,
              which this flake sets in modules/misc/networking.nix. Re-enable it or
              drop the egress-only flags.
            '';
          }
        ];

        # see `BindReadOnlyPaths`
        environment.etc = mkIf (cfg.nameservers != [ ]) {
          "egress-only/resolv.conf".text =
            concatStringsSep "\n" (map (server: "nameserver ${server}") cfg.nameservers) + "\n";
        };

        # the namespace reaches the internet by routing through the host.
        boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

        # filter forwarding to ensure only intended interfaces may do so.
        networking.firewall.filterForward = true;
        networking.firewall.extraForwardRules = ''
          iifname "${hostVeth}" accept
        '';

        systemd.services.${unitName} = {
          description = "Egress-only network namespace";
          wantedBy = [ "multi-user.target" ];
          before = [ "network.target" ];
          restartIfChanged = false;

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
          };

          script =
            let
              ip = "${pkgs.iproute2}/bin/ip";
              sysctl = "${pkgs.procps}/bin/sysctl";
            in
            ''
              set -eu
              ${ip} netns del ${nsArg} 2>/dev/null || true
              ${ip} netns add ${nsArg}
              ${ip} link del ${escapeShellArg hostVeth} 2>/dev/null || true

              ${ip} link add ${escapeShellArg hostVeth} type veth peer name ${escapeShellArg nsVeth}
              ${ip} link set ${escapeShellArg nsVeth} netns ${nsArg}
              ${ip} addr add ${hostAddress}/30 dev ${escapeShellArg hostVeth}
              ${ip} link set ${escapeShellArg hostVeth} up

              ${ip} -n ${nsArg} link set lo up
              ${ip} -n ${nsArg} addr add ${address}/30 dev ${escapeShellArg nsVeth}
              ${ip} -n ${nsArg} link set ${escapeShellArg nsVeth} up
              ${ip} -n ${nsArg} route add default via ${hostAddress}

              # A veth gets a link-local IPv6 address on both ends, which would
              # give the namespace an on-link path to the host. No IPv6 is
              # routed here, so switch it off on the link itself.
              ${sysctl} -qw net.ipv6.conf.${hostVeth}.disable_ipv6=1
              ${ip} netns exec ${nsArg} ${sysctl} -qw net.ipv6.conf.${nsVeth}.disable_ipv6=1
            '';
        };

        # rules to prevent access to LAN
        networking.nftables.tables.${namespace} = {
          family = "ip";
          content = ''
            chain forward {
              type filter hook forward priority filter; policy accept;
              iifname ${escapeShellArg hostVeth} ip daddr { ${concatStringsSep ", " blockedRanges} } drop
            }

            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;
              ip saddr ${address} masquerade
            }
          '';
        };
      };
    };
}
