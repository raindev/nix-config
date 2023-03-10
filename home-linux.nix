{ ... }:
{
  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    extraConfig = "AddKeysToAgent yes";
  };
  home.file = {
    ".bashrc".source = home/linux/bashrc;
    ".profile".source = home/linux/profile;
    ".tmux.conf".source = home/linux/tmux.conf;
  };
}
