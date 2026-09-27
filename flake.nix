{
  inputs = {
    dendritic.url = ./lib/dendritic.nix;
    dendritic.flake = false;
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs@{ dendritic, nixpkgs, ... }:
    let
      evalFlake = (import dendritic { inherit (nixpkgs) lib; }).evalFlake;
    in
    evalFlake ./modules inputs;
}
