{
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.hjem.url = "github:feel-co/hjem";
  inputs.hjem.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.preservation.url = "github:nix-community/preservation";
  inputs.systems.url = "github:nix-systems/x86_64-linux";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs: import ./outputs.nix inputs;
}
