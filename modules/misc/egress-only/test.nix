{
  config,
  inputs,
  ...
}:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;

  egressOnlyModule = config.modules.egress-only.nixos;
in
{
  topLevel.checks = eachSystem (pkgs: {
    egress-only = pkgs.testers.nixosTest {
      name = "egress-only";

      nodes = {
        # stand-in for the internet in this test.
        # ip is from RFC 6890 (TEST-NET-3)
        wan =
          { pkgs, ... }:
          {
            virtualisation.vlans = [ 1 ];
            networking = {
              useDHCP = false;
              firewall.enable = false;
            };

            systemd.services.internet = {
              wantedBy = [ "multi-user.target" ];
              preStart = ''
                ${pkgs.iproute2}/bin/ip addr replace 203.0.113.1/24 dev eth1
              '';
              serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8080 --bind 203.0.113.1";
            };
          };

        machine =
          { pkgs, ... }:
          {
            imports = [ egressOnlyModule ];

            virtualisation.vlans = [ 1 ];

            networking = {
              useDHCP = false;
              nftables.enable = true;
              defaultGateway = "192.168.1.2";
              # deliberately off: would mask our mitigations and cgroup filter
              firewall.enable = false;
            };

            environment.systemPackages = [
              pkgs.curl
              pkgs.iproute2
              pkgs.iputils
              pkgs.nftables
            ];

            systemd.services.sleeper = {
              egress-only = true;
              wantedBy = [ "multi-user.target" ];
              serviceConfig.PrivateUsers = true;
              serviceConfig.ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
            };

            # loopback must keep working with an empty IPAddressAllow list.
            systemd.services.echo = {
              egress-only = true;
              wantedBy = [ "multi-user.target" ];
              serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8081 --bind 127.0.0.1";
            };

            # reachable from the host, must stay
            # unreachable from the namespace even though the route exists.
            systemd.services.host-echo = {
              wantedBy = [ "multi-user.target" ];
              serviceConfig.ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8082 --bind 0.0.0.0";
            };

            # started from the test script, after the far end is ready.
            systemd.services.probe = {
              egress-only = true;
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.curl}/bin/curl -fsS http://203.0.113.1:8080/";
              };
            };

            systemd.services.probe-loopback = {
              egress-only = true;
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.curl}/bin/curl -fsS http://127.0.0.1:8081/";
              };
            };

            # expected to fail: a member's own socket to the host leg is denied
            # by the cgroup filter, and the host listener is up to prove it.
            systemd.services.probe-host-leg = {
              egress-only = true;
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.curl}/bin/curl -fsS --connect-timeout 2 http://10.77.0.1:8082/";
              };
            };
          };
      };

      testScript = ''
        start_all()

        wan.wait_for_unit("internet.service")
        machine.wait_for_unit("netns-egress-only.service")
        machine.wait_for_unit("sleeper.service")
        machine.wait_for_unit("echo.service")
        machine.wait_for_unit("host-echo.service")

        # membership
        pid = machine.succeed("systemctl show -p MainPID --value sleeper.service").strip()
        assert machine.succeed("ip netns identify " + pid).strip() == "egress-only"

        # cgroup filter is in place, and no allow-list survives
        assert "10.0.0.0/8" in machine.succeed("systemctl show -p IPAddressDeny --value sleeper.service")
        assert machine.succeed("systemctl show -p IPAddressAllow --value sleeper.service").strip() == ""

        # no IPv6 link-local on either end of the veth
        assert "fe80" not in machine.succeed("ip -6 addr show dev veth-egressonly")
        assert "fe80" not in machine.succeed("ip netns exec egress-only ip -6 addr")

        # egress through NAT, from inside member units
        machine.succeed("systemctl start probe.service")

        # loopback works with the empty allow-list
        machine.succeed("systemctl start probe-loopback.service")

        # LAN peer reachable from the host, and it is where we think it is
        machine.succeed("ping -c1 -W1 192.168.1.2")

        # ... but not from the namespace
        machine.fail("ip netns exec egress-only ping -c1 -W1 192.168.1.2")

        # the link is up: outside any member cgroup the host leg answers
        machine.succeed("ip netns exec egress-only ping -c1 -W1 10.77.0.1")
        assert "default via 10.77.0.1" in machine.succeed("ip netns exec egress-only ip route")

        # the host listener answers on both addresses ...
        machine.succeed("curl -fsS --connect-timeout 2 http://10.77.0.1:8082/")
        machine.succeed("curl -fsS --connect-timeout 2 http://192.168.1.1:8082/")

        # ... while a member's own socket to the same address is denied
        machine.fail("systemctl start probe-host-leg.service")

        # both chains are installed
        assert "masquerade" in machine.succeed("nft list ruleset")
      '';
    };
  });
}
