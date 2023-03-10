{ ... }:
{
    programs.ssh.matchBlocks."pi4.local netcup.raindev.io" = {
      # Leave it to SSH to forward ssh-agent socket, rather than exposing the GPG agent socket directly.
      # One benefit is that ssh will set SSH_AUTH_SOCK without a need for server configuration.
      forwardAgent = true;
    };
}
