args:
let
  importLib = path: import path args;
in
rec {
  dendritic = importLib ./dendritic.nix;
  inherit (dendritic) mkFlake;

  utils = importLib ./utils.nix;
  inherit (utils) eachSystemWith;
}
