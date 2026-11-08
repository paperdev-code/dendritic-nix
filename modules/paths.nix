{ lib, ... }:
let
  inherit (lib) mapAttrs pathExists;

  flakeRoot = ../.;

  withDiagnostic = path: diag: { inherit path diag; };

  getPath =
    type: head: tail:
    let
      path = "${flakeRoot}/${head}/${tail}";
    in
    withDiagnostic (
      if pathExists path then path else null
    ) "error: `path.${type}` nonexistent path '${head}/${tail}'";

  mkMethods =
    resolve:
    {
      dotfile = "dotfiles";
      root = ".";
    }
    |> mapAttrs getPath
    |> mapAttrs (
      _: fn: tail:
      resolve (fn tail)
    );

  paths = mkMethods (result: with result; if path != null then path else abort diag);
  pathsOptional = mkMethods (result: with result; if path != null then [ path ] else [ ]);
in
{
  _module.args.paths = paths // {
    optional = pathsOptional;
  };
}
