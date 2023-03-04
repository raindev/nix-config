{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "black";

  services.borgmatic.settings.hooks.healthchecks =
    "https://hc-ping.com/fc3b4080-e50e-4512-95ac-0c0981eacdd1";

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    obs-studio
    lutris
  ];

  system.stateVersion = "22.05";
}
