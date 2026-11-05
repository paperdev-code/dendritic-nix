{ lib, ... }:
let
  inherit (lib) mapAttrs pathExists;

  flakeRoot = ../.;

  getPath =
    head: tail:
    let
      path = "${flakeRoot}/${head}/${tail}";
    in
    if pathExists path then path else abort "error: nonexistent path '${head}/${tail}'";
in
{
  _module.args.paths =
    {
      dotfile = "dotfiles";
      keys = "keys";
      root = ".";
    }
    |> mapAttrs (_: dir: getPath dir);
}
