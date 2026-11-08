args:
let
  importLib = path: import path args;
in
rec {
  dendritic = importLib ./dendritic.nix;
  inherit (dendritic) mkFlake;

  hjem = importLib ./hjem.nix;
  inherit (hjem) hjemHome;

  utils = importLib ./utils.nix;
  inherit (utils) eachSystemWith;
}
