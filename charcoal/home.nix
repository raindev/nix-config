{ lib, ... }:
{
  home.username = lib.mkForce "abarchuk";
  home.homeDirectory = lib.mkForce "/home/abarchuk";
}
