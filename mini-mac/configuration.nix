{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustup
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # run Nix GC monthly
  nix.gc.interval.Day = 1;

  system.stateVersion = 4;
}
