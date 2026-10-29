{ config, lib, ... }:
{
  readme = lib.mkOrder config.chapters.hosts ''
    ## Hosts

    NixOS configurations described by this flake.
  '';
}
