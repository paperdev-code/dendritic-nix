{ config, ... }:
{
  # used for namespaces where options aren't applied.
  # for ex. persistence on systems without persistence.
  modules.stubs.nixos = {
    hjem.extraModules = [ config.modules.stubs.hjem ];
  };

  modules.stubs.hjem = { };
}
