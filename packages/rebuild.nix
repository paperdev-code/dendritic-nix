{
  writeShellApplication,
}:
writeShellApplication {
  name = "rebuild";
  inheritPath = true;
  text = ''
    method="''${1:-}"
    if [[ -z "$method" ]]; then
      echo "missing method (e.g. switch, boot)"
      exit 1
    fi
    flakeDir="''${2:-.}"
    storePath=$(nix build \
      "path:$flakeDir#nixosConfigurations.$(hostname).config.system.build.toplevel" \
      --print-out-paths \
      --no-link)
    doas "$storePath/bin/switch-to-configuration" "$method"
  '';
}
