# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd = {
    secrets = { "/crypto_keyfile.bin" = null; };
    luks = {
      fido2Support = true;
      devices."luks-2c58bfa3-2e6d-4577-9e64-57708c703a32".fido2 = {
	# Doesn't work, resuting in "FIDO device can't be found" and "wrong secrete"
        #passwordLess = true;
        credential = "3deef164ba85a60c1674e1924a98526412c781bb11b41ee82491009d8d29596b6f8c2b41f09f85c3fe71508296da1e82";
      };
    };
  };

  networking.hostName = "xps13"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us,ua,de,ru";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # name resolution is broken with the default openresolv implementation
  services.resolved.enable = true;

  services.borgmatic = {
    enable = true;
    settings = {
      location = {
        source_directories = [
          "/etc/nix"
          "/etc/nixos"
          "/home"
          "/boot"
          "/var/lib"
        ];
        exclude_patterns = [
          "/home/*/.cache/"
          "/home/*/.local/share/Trash/"
        ];
        repositories = [ "/data/backup/borg" ];
      };
      retention = {
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
      };
      storage.compression = "zstd";
      hooks.healthchecks = "https://hc-ping.com/512bdad9-2539-470a-9fd7-55f546c8953c";
    };
  };
  # NFS does not allow root access by default (root_squash)
  #systemd.services.borgmatic.serviceConfig = {
  #  User = "raindev";
  #};
  # Update: systemd-inhibit used by the unit requires root privilleges.
  # Rather than messing with the unit more I've enabled no_root_squash

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.raindev = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-option
    wget
    xclip
    wl-clipboard
    tree
    exa
    fd
    ripgrep
    git
    # pass extensions have to be before pass itself in the list
    passExtensions.pass-otp
    (pass.withExtensions (ext: with ext; [ pass-otp ]))
    neovim
    neovim-qt
    bash-completion
    tmux
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

    gnumake
    gcc
    shellcheck
    rustup
    rust-script

    # LSP servers
    rust-analyzer
    rnix-lsp
    sumneko-lua-language-server
    nodePackages.bash-language-server
  ];

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  };
  #programs.steam.enable = true;

  # List services that you want to enable:
  services.syncthing = {
    enable = true;
    user = "raindev";
    dataDir = "/home/raindev";
    overrideFolders = false;
    overrideDevices = false;
  };

  fileSystems."/data" = {
    device = "pi4:/data";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
