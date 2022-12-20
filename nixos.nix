{ ... }:

{
  # run hardlink deduplication for nix store every night
  nix.optimise.automatic = true;

  # catch up on runs missed due to machine being powered off
  nix.gc.persistent = true;

  # catch up on runs missed due to machine being powered off
  systemd.timers.nix-optimise.timerConfig = {
    Persistent = true;
  };
}
