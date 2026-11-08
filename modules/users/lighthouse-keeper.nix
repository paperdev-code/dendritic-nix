{
  config,
  inputs,
  lib,
  ...
}:
let
  allSystems = import inputs.systems;
  eachSystem = inputs.self.lib.eachSystemWith allSystems inputs.nixpkgs.legacyPackages;
in
{
  readme = lib.mkOrder (config.chapters.hosts + 3) ''
    ### Lighthouse

    `(convoluted build command)`

    _Not actually a NixOS host!_

    Instead, an existing VPS with a managed user named "keeper".

    Features:

    - Home managed by Hjem.
    - FRP.
  '';

  topLevel.hjemConfigurations = eachSystem (pkgs: {
    lighthouse-keeper = inputs.self.lib.hjemHome {
      inherit pkgs;
      modules = [ config.modules.users.keeper.hjem ];
    };
  });

  modules.users.keeper.hjem = _: {
    imports = with config.classes.hjem; [
      hjem-standalone
      nix
      programs.helix
      programs.utils
    ];

    name = "keeper";
  };
}
