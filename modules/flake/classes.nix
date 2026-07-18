{ config, lib, ... }:
let
  inherit (lib) foldlAttrs mkOption types;
in
{
  options.classes = mkOption {
    type = with types; lazyAttrsOf (lazyAttrsOf deferredModule);
    readOnly = true;
  };

  config.classes =
    config.modules
    |> foldlAttrs (
      acc: moduleName: classes:
      classes
      |> foldlAttrs (
        acc': className: module:
        acc'
        // {
          ${className} = (acc'.${className} or { }) // {
            ${moduleName} = module;
          };
        }
      ) acc
    ) { };
}
