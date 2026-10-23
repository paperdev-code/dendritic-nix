{ lib, ... }:
let
  inherit (lib) mapAttrs mkOption types;

  classify =
    moduleName: className: module:
    if className == "generic" then module else module // { _class = className; };

  classifyModules = mapAttrs (moduleName: mapAttrs (classify moduleName));
in
{
  options.modules = mkOption {
    type = with types; attrsOf (attrsOf deferredModule);
    apply = classifyModules;
  };
}
