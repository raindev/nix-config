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

  time.timeZone = "Europe/Berlin";
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
    overrideFolders = false;
    overrideDevices = false;
  };
  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    xclip
    wl-clipboard

    gcc
    shellcheck
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
    plexamp

    tdesktop
    signal-desktop
    element-desktop
    discord
    zulip
  ];

}
