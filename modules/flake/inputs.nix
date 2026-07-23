{ lib, ... }:
let
  inherit (lib)
    attrValues
    concatStringsSep
    flatten
    mapAttrs
    mkOption
    types
    ;

  inputFollowsModule = {
    options.follows = mkOption {
      type = types.str;
    };
  };

  inputModule = {
    options.url = mkOption {
      type = types.str;
    };

    options.inputs = mkOption {
      type = with types; attrsOf (submodule inputFollowsModule);
      default = { };
    };
  };

  toInputLine = name: cfg: [
    "    ${name}.url = \"${cfg.url}\";"
    (
      cfg.inputs
      |> mapAttrs (input: follows: "    ${name}.inputs.${input}.follows = \"${follows.follows}\";")
      |> attrValues
    )
  ];
in
{
  options.inputs = mkOption {
    type = with types; attrsOf (submodule inputModule);
    apply =
      inputs:
      inputs
      |> mapAttrs toInputLine
      |> attrValues
      |> (
        src:
        [
          "  inputs = {"
          src
          "  };"
        ]
        |> flatten
        |> concatStringsSep "\n"
      );
  };
}
