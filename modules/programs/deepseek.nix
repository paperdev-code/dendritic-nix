{ inputs, ... }:
{
  modules.programs.deepseek.hjem = { pkgs, ... }: {
    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.dsh
    ];

    persistence.directories = [
      ".dsh"
    ];
  };
}
