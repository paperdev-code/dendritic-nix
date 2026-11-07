{
  config,
  inputs,
  ...
}:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  topLevel.checks = eachSystem (
    pkgs:
    let
      # tests whether evsieve works and is readable by the dashboard user
      evsieveTest = pkgs.writers.writePython3Bin "test-dashboard-evsieve" {
        libraries = [ pkgs.python3Packages.evdev ];
        doCheck = false;
      } (builtins.readFile ./test-evsieve.py);
    in
    {
      dashboard = pkgs.testers.nixosTest {
        name = "dashboard";

        nodes.machine = {
          imports = [ config.modules.services.dashboard.nixos ];

          environment.systemPackages = [ evsieveTest ];

          services.dashboard.hardware.keyboard = {
            path = "/dev/input/by-path/test-keyboard";
            id = "test-keyboard";
          };

          services.dashboard.hardware.gamepad = {
            path = "/dev/input/by-id/test-gamepad";
            id = "test-gamepad";
          };
        };

        testScript = ''
          machine.start();
          machine.wait_for_unit("multi-user.target");
          machine.wait_for_unit("dashboard.service");
          machine.succeed("modprobe uinput");
          machine.wait_for_file("/dev/uinput");
          machine.succeed("udevadm settle");
          machine.succeed("test-dashboard-evsieve");
        '';
      };
    }
  );
}
