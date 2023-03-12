{ lib, ... }:
{
  home.username = lib.mkForce "abarchuk";
  home.homeDirectory = lib.mkForce "/home/abarchuk";
  programs.git.userEmail = lib.mkForce "andrew.barchuk@zalando.de";
  programs.git.signing.key = lib.mkForce "7B7AA60DC00AF73A3820C609F89D58E0FA4F7AD4";
}
