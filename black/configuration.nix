{ outputs, config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  networking.hostName = "black";

  services.borgmatic.settings.hooks.healthchecks =
    "https://hc-ping.com/fc3b4080-e50e-4512-95ac-0c0981eacdd1";

  services.openssh.enable = true;
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
    obs-studio
    lutris
    logseq

    gcc
    rustup
    shellcheck

    # LSP servers
    rust-analyzer
  ];

  system.stateVersion = "22.05";
}
