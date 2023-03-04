{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "xps13";

  services.borgmatic.settings.hooks.healthchecks =
    "https://hc-ping.com/512bdad9-2539-470a-9fd7-55f546c8953c";

  system.stateVersion = "22.05";
}
