{ ... }:

{
  environment.variables.EDITOR = "nvim";

  nix = {
    settings = {
      # allow use of nix command and flakes
      experimental-features = [ "nix-command" "flakes" ];
      # run hardlink deduplication for nix store
      auto-optimise-store = true;
    };
    gc = {
      # remove unused files from nix storage
      automatic = true;
      # remove obsolete generations
      options = "--delete-older-than 30d";
    };
  };
}
