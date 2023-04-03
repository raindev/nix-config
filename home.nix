{ lib, ... }:

{
  home.username = "raindev";
  home.homeDirectory = "/home/raindev";

  programs.home-manager.enable = true;

  home.stateVersion = "22.11";
}
