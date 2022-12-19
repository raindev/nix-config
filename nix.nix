{ ... }:

{
  # allow use of nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    # remove unused files from nix storage
    automatic = true;
    # catch up on runs missed due to machine being powered off
    persistent = true;
    # remove obsolete generations
    options = "--delete-older-than 30d";
  };
  # run hardlink deduplication for nix store every night
  nix.optimise.automatic = true;
  # catch up on runs missed due to machine being powered off
  systemd.timers.nix-optimise.timerConfig = {
    Persistent = true;
  };

}
