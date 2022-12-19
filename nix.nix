{ ... }:

{
  # allow use of nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    # remove unused files from nix storage
    automatic = true;
    # remove obsolete generations
    options = "--delete-older-than 30d";
  };
  # run hardlink deduplication for nix store every night
  nix.optimise.automatic = true;

}
