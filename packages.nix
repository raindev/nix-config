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
    nixos-option
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
