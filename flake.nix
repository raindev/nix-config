{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-hardware, darwin, ... }: {
    nixosConfigurations = {
      xps13 = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-hardware.nixosModules.dell-xps-13-9380
          ./packages.nix
          ./xps13/configuration.nix
        ];
      };
      black = nixpkgs.lib.nixosSystem {
        modules = [
          ./packages.nix
          ./black/configuration.nix
        ];
      };
    };
    darwinConfigurations."mini-mac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./mini-mac/configuration.nix
        ./packages.nix
      ];
    };
  };
}
