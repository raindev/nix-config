{ pkgs, ... }:

{
  # enable local network hostname resolution without relying on DNS
  services.avahi.nssmdns = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.night-theme-switcher
  ];


  fileSystems."/data" = {
    device = "pi4.local:/data";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/backup" = {
    device = "pi4.local:/external";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };
}
