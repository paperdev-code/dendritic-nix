{
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:niri-wm/niri?ref=v26.04";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./outputs.nix inputs;
}
