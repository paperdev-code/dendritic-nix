{ lib, ... }:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;

  classify =
    moduleName: className: module:
    if className == "any" then module else { _class = className; } // module;

  classifyModules = mapAttrs (moduleName: mapAttrs (classify moduleName));
in
{
  options.modules = mkOption {
    type = with types; lazyAttrsOf (lazyAttrsOf deferredModule);
    apply = classifyModules;
  };
}
