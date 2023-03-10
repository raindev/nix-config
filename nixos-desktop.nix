{ pkgs, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };

  security.sudo.wheelNeedsPassword = false;

  networking.networkmanager.enable = true;
  services.resolved.enable = true;
  # enable local network hostname resolution without relying on DNS
  services.avahi.nssmdns = true;

  fileSystems."/data" = {
    device = "pi4.local:/data";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };
  fileSystems."/backup" = {
    device = "pi4.local:/external";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  i18n.defaultLocale = "en_GB.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.utf8";
    LC_IDENTIFICATION = "de_DE.utf8";
    LC_MEASUREMENT = "de_DE.utf8";
    LC_MONETARY = "de_DE.utf8";
    LC_NAME = "de_DE.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "de_DE.utf8";
    LC_TELEPHONE = "de_DE.utf8";
    LC_TIME = "de_DE.utf8";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us,ua,de,ru";
  };

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # The extra socket is used for GPG agent forwarding via SSH
    enableExtraSocket = true;
  };
  services.syncthing = {
    enable = true;
    user = "raindev";
    dataDir = "/home/raindev";
  };
  environment.systemPackages = with pkgs; [
    xclip
    wl-clipboard
    # install gitk as well
    (git.override { guiSupport = true; })

    gcc
    rustup
    rust-script
    rust-analyzer

    gnome.gnome-tweaks
    gnome.gnome-shell-extensions
    gnome.pomodoro
    gnomeExtensions.appindicator
    gnomeExtensions.night-theme-switcher

    neovim-qt
    wezterm
    firefox
    logseq
    meld
    spotify
    plexamp

    tdesktop
    signal-desktop
    element-desktop
    discord
    zulip
  ];

  home-manager.users.raindev = {
    imports = [ ./desktop.nix ];
    xdg.configFile."autostart/gnome-keyring-ssh.desktop".source = home/gnome-keyring-ssh.desktop;
    programs.ssh.matchBlocks."pi4.local netcup.raindev.io".extraOptions = {
      "RemoteForward" = "/run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
    };
  };

}
