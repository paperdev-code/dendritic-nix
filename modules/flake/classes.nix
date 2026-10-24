{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (inputs.self.lib.dendritic) isLeaf;
  inherit (lib)
    any
    concatLists
    concatStringsSep
    findFirst
    foldl'
    length
    mapAttrsToList
    mkOption
    recursiveUpdate
    setAttrByPath
    take
    types
    ;

  # module represented in human-readable form relative to `modules`
  modulePath = leaf: concatStringsSep "." ([ "modules" ] ++ leaf.path ++ [ leaf.class ]);

  collectLeaves =
    path: node:
    node
    |> mapAttrsToList (
      name: value:
      if name == "_class" then
        [ ]
      else if isLeaf value then
        [
          {
            class = value._class or "generic";
            inherit path;
            module = value;
          }
        ]
      else
        collectLeaves (path ++ [ name ]) value
    )
    |> concatLists;

  classPath = leaf: [ leaf.class ] ++ leaf.path;
  isPrefix = prefix: path: take (length prefix) path == prefix;

  # if one class path is a prefix of another, a module and namespace would occupy the same node.
  assertNoCollision =
    leaves:
    let
      paths = map classPath leaves;
      conflicts = path: any (other: path != other && isPrefix path other) paths;
      bad = findFirst (leaf: conflicts (classPath leaf)) null leaves;
    in
    if bad == null then
      leaves
    else
      throw "class path collision at '${modulePath bad}': path is both a class module and a namespace";

  buildClasses =
    leaves:
    foldl' (
      classes: leaf: recursiveUpdate classes (setAttrByPath (classPath leaf) leaf.module)
    ) { } leaves;
in
{
  options.classes = mkOption {
    type = types.attrs;
    readOnly = true;
  };

  config.classes = collectLeaves [ ] config.modules |> assertNoCollision |> buildClasses;
}
