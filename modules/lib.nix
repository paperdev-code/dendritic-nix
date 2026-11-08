{ inputs, lib, ... }:
{
  topLevel.lib = import ../lib {
    inherit lib;
    inherit inputs;
    topLevel = true;
  };
}
