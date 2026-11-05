# Dendritic Nix

:construction:

## Hosts

NixOS configurations described by this flake.

### Dawnstar

`nixos-rebuild build .#dawnstar`

My NixOS workstation and daily driver.

Features:

- Impermanence using nix preservation and tmpfs.
- Umbriel and Noctalia based desktop environment.

(screenshot)

### Stendarr

`nix run github:nix-community/nixos-anywhere -- --flake .#stendarr build --target-host root@<ip address>`

A NixOS powered _Acer Nitro Blaze 7_ to run a GregTech NH server.

Features:

- Also ephemeral using nix preservation and tmpfs.
- OpenSSH server for remote configuration.

(silly image)
