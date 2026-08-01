{
  inputs = {
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    hjem.url = "github:feel-co/hjem";
    hjem.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.inputs.systems.follows = "systems";
    llm-agents.inputs.treefmt-nix.follows = "treefmt-nix";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    noctalia-greeter.url = "github:noctalia-dev/noctalia-greeter";
    noctalia-greeter.inputs.nixpkgs.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./outputs.nix inputs;
}
