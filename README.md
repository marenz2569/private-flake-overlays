# private-flake-overlays
Add confidential or private configurations and packages to your public flake.

## Concept
Serval solutions exsits for encrypting private nix-configs are secrets:
- sops
- gitcrypt?
But all are either clumsy to user or only encrypt secrets.
Private flake overlays are a concept to share your public flakes while keeping secret configurations/packages/modules hidden from the public up until deployment.

Overlays applied to one or multiple hosts and whole nixosConfigurations are stored in the standard flake format.

## Use Cases

### Provide a private nixos configuration to a public flake

TODO: basically define a normal nixos configuration

### Provide overlays to specific hosts

TODO: basically a nixos module that is applied based on name or group (?)
