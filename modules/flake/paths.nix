{ lib, ... }:
let
  inherit (lib) mapAttrs pathExists;

  validate = path: if pathExists path then path else abort "error: nonexistent path '${path}'";

  flakeRoot = ../../.;
in
{
  config._module.args.paths =
    {
      dotfile = "dotfiles";
      root = ".";
    }
    |> mapAttrs (
      _: dir: path:
      validate "${flakeRoot}/${dir}/${path}"
    );
}
