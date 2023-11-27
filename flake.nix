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
        filteredNixosConfigurations =
          nixpkgs.lib.filterAttrs (k: v: k == "nixosConfigurations") flake;

        overlayedNixosConfigurations = other // filteredNixosConfigurations;

        mapMatchingNixosModule = name: config:
          if flake ? nixosModules && flake.nixosModules ? name then
            config.extendModules { modules = [ flake.nixosModules.${name} ]; }
          else
            config;
      in overlayedNixosConfigurations // (if other ? nixosConfigurations then {
        nixosConfiguration =
          nixpkgs.lib.mapAttrs mapMatchingNixosModule other.nixosConfigurations;
      } else
        { });
  };
}
