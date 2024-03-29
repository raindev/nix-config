{ lib, ... }:

{
  home.username = "raindev";
  home.homeDirectory = "/home/raindev";

  programs.home-manager.enable = true;

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    extraConfig = "AddKeysToAgent yes";
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Andrew Barchuk";
    userEmail = "andrew@raindev.io";
    signing.key = "B14FD6B79497FC060E88564D548706C0A2EEA361";
    signing.signByDefault = true;
    aliases = {
      continue = "!f() { git commit --edit --file=$(git rev-parse --git-dir)/COMMIT_EDITMSG; }; f";
    };
    ignores = [ "*~" "*.swp" "*.swo" ];
    extraConfig = {
      init.defaultBranch = "main";
      pull.ff = "only";
      push.autoSetupRemote = true;
    };
  };

  home.activation.wezterm = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sf ~/code/nix-config/home/wezterm.lua ~/.wezterm.lua
  '';
  home.file.".bash_functions".source = home/bash_functions;
  xdg.configFile."nvim".source = home/nvim;
  home.file.".curlrc".text = ''--write-out "\n"'';

  home.stateVersion = "22.11";
}
