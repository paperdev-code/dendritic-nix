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
    doas -u "$USER" nixos-rebuild build --flake "path:$flakeDir#"
    doas nixos-rebuild "$method" --flake "path:$flakeDir#"
  '';
}
