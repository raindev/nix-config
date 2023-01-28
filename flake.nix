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

  outputs = { nixpkgs, nixpkgs-small, nixpkgs-small-2205, darwin, nixos-hardware, ... }:
    let
      system = "aarch64-linux";
      overlay-2205 = final: prev: {
        old = import nixpkgs-small-2205 {
          inherit system;
          config.allowUnfree = true;
        };
      };

    in {
    nixosConfigurations = {
      xps13 = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-hardware.nixosModules.dell-xps-13-9380
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ./nixos-desktop.nix
          ./xps13/configuration.nix
        ];
      };
      black = nixpkgs.lib.nixosSystem {
        modules = [
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ./nixos-desktop.nix
          ./black/configuration.nix
        ];
      };
      pi4 = nixpkgs-small.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-2205 ]; })
          ./pi4/configuration.nix
        ];
      };
      netcup = nixpkgs-small.lib.nixosSystem {
        modules = [
          ./nix.nix
          ./packages.nix
          ./nixos.nix
          ./netcup/configuration.nix
        ];
      };
    };
    darwinConfigurations."mini-mac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./nix.nix
        ./packages.nix
        ./mini-mac/configuration.nix
      ];
    };
  };
}
