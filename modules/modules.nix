{ lib, ... }:
let
  inherit (lib)
    filterAttrs
    mapAttrs
    mkOption
    types
    ;

  classify =
    moduleName: className: module:
    if className == "generic" then module else { _class = className; } // module;

  lazyModule = {
    freeformType = with types; lazyAttrsOf (nullOr deferredModule);
  };
in
{
  options.modules = mkOption {
    type = with types; lazyAttrsOf (submodule lazyModule);
    apply =
      modules:
      modules
      |> mapAttrs (_: filterAttrs (_: module: module != null))
      |> mapAttrs (moduleName: mapAttrs (classify moduleName));
  };
}
