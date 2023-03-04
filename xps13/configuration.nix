{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "xps13";

  services.borgmatic.settings.hooks.healthchecks =
    "https://hc-ping.com/512bdad9-2539-470a-9fd7-55f546c8953c";

  environment.systemPackages = with pkgs; [
    nixos-option
    xclip
    wl-clipboard
    # pass extensions have to be before pass itself in the list
    passExtensions.pass-otp
    (pass.withExtensions (ext: with ext; [ pass-otp ]))
    neovim-qt
    bash-completion
    wezterm
    meld
    gnome.gnome-tweaks
    gnome.gnome-shell-extensions
    gnome.pomodoro
    gnomeExtensions.appindicator
    plexamp
    tdesktop
    element-desktop
    signal-desktop
    discord
    zulip
    logseq

    gcc
    shellcheck
    rustup
    rust-script

    # LSP servers
    rust-analyzer
  ];

  system.stateVersion = "22.05";
}
