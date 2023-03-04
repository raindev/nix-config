{ outputs, pkgs, ... }:

{
  nixpkgs.overlays = [ outputs.overlays.modifications ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # command line tools
    exa
    fd
    gnupg
    git
    git-lfs
    gnumake
    neovim
    ripgrep
    tmux
    tree
    wget
    watchexec

    # LSP servers
    rnix-lsp
    sumneko-lua-language-server
    nodePackages.bash-language-server
  ];
}
