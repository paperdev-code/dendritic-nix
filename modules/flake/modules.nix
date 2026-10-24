{ inputs, lib, ... }:
let
  inherit (inputs.self.lib.dendritic) isLeaf;
  inherit (lib)
    isFunction
    isPath
    mapAttrs
    mkOption
    types
    ;

  # a module is a function or path, attrs are namespaces.
  module = types.deferredModule // {
    name = "classModule";
    check = x: isFunction x || isPath x;
  };

  moduleTree = types.attrsOf (types.either module moduleTree);

  classifyModules =
    tree:
    tree
    |> mapAttrs (
      name: value:
      if isLeaf value then
        (if name == "generic" then value else value // { _class = name; })
      else
        classifyModules value // { _class = "namespace"; }
    );
in
{
  options.modules = mkOption {
    type = moduleTree;
    apply = classifyModules;
  };
}
