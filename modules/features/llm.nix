{ config, ... }:
{
  modules.llm.hjem = {
    imports = with config.classes.hjem; [
      aichat
      llamaServer
    ];
  };
}
