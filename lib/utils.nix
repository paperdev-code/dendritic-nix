{ lib, ... }:
let
  inherit (lib)
    elemAt
    foldl'
    genAttrs
    length
    mul
    range
    ;
in
{
  eachSystemWith =
    systems: packages: f:
    genAttrs systems (system: f packages.${system});

  enumerate =
    scalar: list:
    (range 0 ((length list) - 1))
    |> foldl' (
      acc: idx:
      acc
      // {
        ${elemAt list idx} = mul idx scalar;
      }
    ) { };
}
