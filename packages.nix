{ outputs, pkgs, ... }:

{
  imports = [
    ./nixpkgs.nix
  ];

  environment.systemPackages = with pkgs; [
    # command line tools
    exa
    fd
    gnupg
    git
    git-lfs
    gnumake
    gnused
    neovim
    ripgrep
    shellcheck
    tmux
    tree
    wget
    watchexec
    bash-completion
    # pass extensions have to be before pass itself in the list
    passExtensions.pass-otp
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    # LSP servers
    rnix-lsp
    sumneko-lua-language-server
    nodePackages.bash-language-server
  ];
}
