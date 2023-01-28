{ pkgs, ... }:

{
  # enable local network hostname resolution without relying on DNS
  services.avahi.nssmdns = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.night-theme-switcher
  ];
}
