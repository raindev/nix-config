{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # run Nix GC monthly
  nix.gc.interval.Day = 1;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # /etc/shells
  environment.shells = [ pkgs.bashInteractive ];

  environment.systemPackages = with pkgs; [
    rustup
  ];

  users.knownUsers = [ "raindev" ];
  # the configuration will not be updated for already existing user
  users.users.raindev = {
    description = "Andrew Barchuk";
    uid = 501;
    gid = 20;
    home = "/Users/raindev";
    createHome = true;
    # chsh
    shell = "${pkgs.bashInteractive}/bin/bash";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.raindev = import ../home.nix;
  };

  system.stateVersion = 4;
}
