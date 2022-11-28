{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs @ { nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations = {
      xps13 = nixpkgs.lib.nixosSystem {
        modules = [
          ./xps13/configuration.nix
          nixos-hardware.nixosModules.dell-xps-13-9380
        ];
      };
    };
  };
}
