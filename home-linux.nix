{ ... }:
{
  # make desktop entries available in the launcher
  targets.genericLinux.enable = true;
  home.file = {
    ".bashrc".source = home/linux/bashrc;
    ".profile".source = home/linux/profile;
    ".tmux.conf".source = home/linux/tmux.conf;
  };
}
