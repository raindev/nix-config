# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "black"; # Define your hostname.
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
          "/home/*/.local/share/Steam/"
        ];
        repositories = [ "/data/backup/borg" ];
      };
      retention = {
        prefix = "{hostname}-";
        keep_daily = 7;
        keep_weekly = 4;
        keep_monthly = 12;
      };
      storage = {
        compression = "zstd";
        archive_name_format = "{hostname}-{now}";
      };
      hooks = {
        healthchecks = "https://hc-ping.com/fc3b4080-e50e-4512-95ac-0c0981eacdd1";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.raindev = {
    isNormalUser = true;
    description = "Andrew";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
  };

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "raindev";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixos-option
    xclip
    wl-clipboard
    # pass extensions have to be before pass itself in the list
    passExtensions.pass-otp
    (pass.withExtensions (ext: with ext; [pass-otp]))
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

  environment.variables.EDITOR = "nvim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    # The extra socket is used for GPG agent forwarding via SSH
    enableExtraSocket = true;
  };

  # List services that you want to enable:
  services.syncthing = {
    enable = true;
    user = "raindev";
    dataDir = "/home/raindev";
    overrideFolders = false;
    overrideDevices = false;
  };

  services.openssh.enable = true;

  programs.steam.enable = true;

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
