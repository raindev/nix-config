{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
  };
  programs.neovim.enable = true;
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };
  programs.exa.enable = true;
  services.syncthing.enable = true;

  home.packages = with pkgs; [
    source-code-pro
    tmux
    wl-clipboard
    xclip
  ];

}
