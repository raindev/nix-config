{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-22.11-small";
    nixpkgs-small-2205.url = "github:nixos/nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-small, nixpkgs-small-2205, darwin, nixos-hardware, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in rec {
    overlays = import ./overlays.nix { inherit inputs; };

    nixosConfigurations = {
      xps13 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          nixos-hardware.nixosModules.dell-xps-13-9380
          ./nix.nix
          ./packages.nix
          ./borgmatic.nix
          ./nixos.nix
          ./nixos-desktop.nix
          ./xps13/configuration.nix
        ];
      };
      black = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./nix.nix
          ./packages.nix
          ./borgmatic.nix
          ./nixos.nix
          ./nixos-desktop.nix
          ./black/configuration.nix
        ];
      };
      pi4 = nixpkgs-small.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ./pi4/configuration.nix
        ];
      };
      netcup = nixpkgs-small.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ./netcup/configuration.nix
        ];
      };
    };
    darwinConfigurations."mini-mac" = darwin.lib.darwinSystem {
      specialArgs = { inherit inputs outputs; };
      modules = [
        ./nix.nix
        ./packages.nix
        ./mini-mac/configuration.nix
      ];
    };
  };
}
