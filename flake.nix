{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-22.11-small";
    nixpkgs-small-2205.url = "github:nixos/nixpkgs/nixos-22.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-small, nixpkgs-small-2205, nixos-hardware, darwin, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    rec {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shells.nix { inherit pkgs; }
      );
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
            ./server.nix
            ./pi4/configuration.nix
          ];
        };
        netcup = nixpkgs-small.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./nix.nix
            ./packages.nix
            ./nixos.nix
            ./server.nix
            ./netcup/configuration.nix
          ];
        };
      };

      darwinConfigurations."mini-mac" = darwin.lib.darwinSystem {
        # has to be specified explicitly
        system = "aarch64-darwin";
        specialArgs = { inherit inputs outputs; };
        modules = [
          ./nix.nix
          ./packages.nix
          ./mini-mac/configuration.nix
        ];
      };

      homeConfigurations = {
        raindev = home-manager.lib.homeManagerConfiguration {
          # for whatever reason homeConfigurations.raindev.activationPackage
          # is missing otherwise
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            ./nixpkgs.nix
            ./home.nix
            ./home-linux.nix
            ./home-manager.nix
          ];
        };
      };

    };
}
