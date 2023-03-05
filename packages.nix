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
    neovim
    ripgrep
    tmux
    tree
    wget
    watchexec
    nixos-option
    bash-completion
    # pass extensions have to be before pass itself in the list
    passExtensions.pass-otp
    (pass.withExtensions (ext: with ext; [ pass-otp ]))

    # LSP servers
    rnix-lsp
    lua-language-server
    nodePackages.bash-language-server
  ];
}
