{
  lib,
  paths,
  ...
}:
let
  inherit (lib) concatStringsSep;
in
{
  modules.llamaServer.hjem = { pkgs, ... }: {
    packages = [
      pkgs.llama-cpp-vulkan
    ];

    systemd.services.llama-server = {
      description = "llama.cpp server";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];

      path = [
        pkgs.llama-cpp-vulkan
      ];

      script =
        let
          args = concatStringsSep " " [
            "--host 127.0.0.1"
            "--port 10110"
            "--models-preset \"$XDG_CONFIG_HOME/llama-cpp/models.ini\""
            "--offline"
            "--sleep-idle-seconds 600"
            "--cors-origins \"http://127.0.0.1:10110\""
          ];
        in
        ''
          mkdir -p "$XDG_STATE_HOME/llama-cpp/models"
          exec llama-server ${args};
        '';

      serviceConfig = {
        Type = "exec";
        Restart = "on-failure";
        RestartSec = 30;

        Environment = [
          "LLAMA_CACHE=%C/llama-cpp"
        ];

        WorkingDirectory = "%h/.local/state/llama-cpp";
        StateDirectory = "llama-cpp";
        CacheDirectory = "llama-cpp";
        ConfigurationDirectory = "llama-cpp";
      };
    };

    files.".config/llama-cpp/models.ini".source = paths.dotfile "llama-cpp/models.ini";

    persistence.directories = [
      ".local/cache/llama-cpp"
      ".local/state/llama-cpp"
    ];
  };
}
