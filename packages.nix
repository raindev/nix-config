{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # command line tools
    exa
    fd
    git
    neovim
    ripgrep
    tmux
    tree
    wget

    # LSP servers
    rnix-lsp
    sumneko-lua-language-server
    nodePackages.bash-language-server
  ];
}
