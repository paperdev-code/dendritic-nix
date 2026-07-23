{
  perl,
  nix,
  writeShellApplication,
}:
writeShellApplication {
  name = "fixup-inputs";
  runtimeInputs = [
    perl
    nix
  ];
  text = ''
    flakeDir="''${1:-.}"
    flakeFile="''${flakeDir}/flake.nix"
    if [ ! -f "$flakeFile" ]; then
      echo "error: could not find '$flakeFile'" >&2
    fi
    flakeInputs=$(nix eval --raw "''${flakeDir}#_debug.config.inputs")
    export flakeInputs
    perl -0777 -i -pe 's/  inputs = \{.*?\};/$ENV{flakeInputs}/s' "$flakeFile"
    echo "success: updated flake inputs" >&2
  '';
}
