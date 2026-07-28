{ config, inputs, ... }:
{
  inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.systems.follows = "systems";
    inputs.treefmt-nix.follows = "treefmt-nix";
  };

  modules.llm.hjem = { pkgs, ... }: {
    imports = with config.classes.hjem; [
      llamaServer
    ];

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.crush
    ];
  };
}
