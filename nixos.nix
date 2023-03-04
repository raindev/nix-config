{ inputs, config, pkgs, lib, ... }: with lib; {

  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # run hardlink deduplication for nix store every night
  nix.optimise.automatic = true;

  # catch up on runs missed due to machine being powered off
  nix.gc.persistent = true;
  nix.gc.dates = "monthly";

  # catch up on runs missed due to machine being powered off
  systemd.timers.nix-optimise.timerConfig = {
    Persistent = true;
  };

  users.users.raindev = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "wheel" ]
      ++ optionals config.networking.networkmanager.enable [ "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    atop
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.raindev = import ./home.nix;
  };
}
