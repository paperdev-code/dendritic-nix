set default-list := true

build host="":
  nixos-rebuild build --flake path:.#{{host}}

sign key path="./result":
  nix store sign --key-file {{key}} --recursive {{path}}

copy-to target path="./result" ssh-opts="-p 2288":
  NIX_SSHOPTS="{{ssh-opts}}" nix-copy-closure --to {{target}} {{path}}
