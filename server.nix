{ pkgs, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    # remove stale sockets on connect (for GPG socker forwarding)
    # https://wiki.archlinux.org/title/GnuPG#Forwarding_gpg-agent_and_ssh-agent_to_remote
    extraConfig = "StreamLocalBindUnlink yes";
  };

  nix.gc = pkgs.lib.mkForce {
    # clean-up unused data more frequently to save space
    dates = "weekly";
    # but keep more generations around
    options = "--delete-older-than 90d";
  };

}
