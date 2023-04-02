{ lib, ... }:

{
  home.username = "raindev";
  home.homeDirectory = "/home/raindev";

  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    extraConfig = "AddKeysToAgent yes";
  };

  home.stateVersion = "22.11";
}
