{
  description =
    "Add confidential or private configurations and packages to your public flake.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = { self, nixpkgs }: {
    lib.overlayFlake = url: other:
      let
        flake = if builtins ? currentSystem then builtins.getFlake url else { };
        # inject nixosconfigurations if they don't already exist
        combinedNixosConfigurations = nixpkgs.lib.zipAttrs [
          (other.nixosConfigurations or { })
          (flake.nixosConfigurations or { })
        ];
        findDuplicate = n: v:
          builtins.length v > 1 && abort
          "nixosConfiguration ${n} cannot be duplicate in both public and private flake";
        _ = nixpkgs.lib.filterAttrs findDuplicate combinedNixosConfigurations;

        overlayedNixosConfigurations = (other.nixosConfigurations or { })
          // (flake.nixosConfigurations or { });

        # filter out all modules where there is not a matching nixosConfiguration
        filterModules = name: module: overlayedNixosConfigurations ? ${name};
        modules =
          nixpkgs.lib.filterAttrs filterModules (flake.nixosModules or { });

        # function to apply a module to a nixosConfiguration
        extendConfigurationWithModule = name: module:
          overlayedNixosConfigurations.${name}.extendModules {
            modules = [ module ];
          };
      in other // {
        nixosConfigurations = overlayedNixosConfigurations
          // (nixpkgs.lib.mapAttrs extendConfigurationWithModule modules);
      };
  };
}
