{ config, ... }:
{
  modules.agents.nixos = _: {
    hjem.extraModules = [ config.modules.agents.hjem ];
  };

  modules.agents.hjem = _: {
    imports = [ config.classes.hjem.programs.deepseek ];
  };
}
