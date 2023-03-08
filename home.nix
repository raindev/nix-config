{ ... }:

{
  home.username = "raindev";

  programs.home-manager.enable = true;

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
  home.file.".curlrc".source = home/curlrc;

  home.stateVersion = "22.11";
}
